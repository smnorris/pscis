import yaml
import os

import pgdb
import fwakit

# load config file
# pscis db should probably be an environment var rather than textfile config
with open(os.path.join(os.path.dirname(__file__),
          "./config.yml"), 'r') as ymlfile:
    cfg = yaml.load(ymlfile)

# connect to db and load queries
db = pgdb.connect(url=cfg["dburl"],
                  sql_path=os.path.join(os.path.dirname(__file__), "sql"))
queries = db.load_queries(os.path.join(os.path.dirname(__file__), "sql"))
updates = db.load_queries(os.path.join(os.path.dirname(__file__),
                          "sql/updates"))


def oneline(string):
    """remove whitespace and newlines from within a text block"""
    return " ".join([r.strip() for r in string.split("\n")])+"\n"


def apply_updates():
    """
    Apply updates that haven't yet made it to BCGW Prod
    """
    for q in updates:
        db.execute(updates[q])


def delete_assessment_sql(crossing_id):
    """
    Generate SQL necessary for deleting all PSCIS records associated with
    a single assessment.
    """
    # define tables from which record should be dropped, and key to match
    tables = {"pscis_attachments":            "assessment_id",
              "pscis_crossing_assessments":   "assessment_id",
              "pscis_structures":             "structure_id",
              "pscis_stream_cross_loc_point": "stream_crossing_id"}
    # load assessment of interest
    assmt = db.query_one("""SELECT * FROM pscis.pscis_crossing_assessments
                            WHERE stream_crossing_id = %s""", crossing_id)
    sql = ""
    for table, column in tables.iteritems():
        sql = sql+"DELETE FROM pscis.{t} WHERE {c} = {v}; \n".format(t=table,
                                                                     c=column,
                                                                     v=assmt[column])
    return sql


def add_missing_fixes():
    """
    As of may 2016 there are 67 recs missing from the remediation view
    Add them to the merged table here
    """
    sql = """INSERT INTO pscis.pscis_points_all
        (SELECT
           p.stream_crossing_id,
           'REMEDIATED'::text AS current_pscis_status,
           'PASSABLE'::text AS current_barrier_result_code,
           p.geom
        FROM pscis.pscis_stream_cross_loc_point p
        INNER JOIN pscis.pscis_structures s
        ON p.stream_crossing_id = s.stream_crossing_id
        WHERE s.structure_id IN
        (8754,8856,8738,8841,8791,8814,8850,8848,8793,8852,
         8860,8838,8737,8772,8796,8799,8792,8751,8818,8812,
         8858,8755,8864,8820,8797,8816,8735,8810,8853,8753,
         8731,8768,8770,8847,8750,8827,8842,8837,8832,8798,
         8851,8854,8859,8840,8741,8855,8839,8809,8779,8771,
         8817,8803,8790,8736,8762,8811,8849,8857,8862,8739,
         8863,8730,8821,8752,8846,8761,8819))"""
    db.execute(sql)


def merge_views():
    """
    Merge points from assessments, designs, remediations into single table
    """
    if "pscis.pscis_points_all" in db.tables:
        db["pscis.pscis_points_all"].drop()
    sql = """CREATE TABLE pscis.pscis_points_all AS
             SELECT
               stream_crossing_id,
               current_pscis_status,
               current_barrier_result_code,
               geom
             FROM pscis.pscis_assessment_svw
             WHERE current_pscis_status = 'ASSESSED'
             UNION ALL
             SELECT
               stream_crossing_id,
               current_pscis_status,
               current_barrier_result_code,
               geom
             FROM pscis.pscis_habitat_confirmation_svw
             WHERE current_pscis_status = 'CONFIRMATION'
             UNION ALL
             SELECT
               stream_crossing_id,
               current_pscis_status,
               current_barrier_result_code,
               geom
             FROM pscis.pscis_design_proposal_svw
             WHERE current_pscis_status = 'DESIGN'
             UNION ALL
             SELECT
               stream_crossing_id,
               current_pscis_status,
               current_barrier_result_code,
               geom
            FROM pscis.pscis_remediation_svw
            WHERE current_pscis_status = 'REMEDIATED'
            """
    db.execute(sql)
    # add indexes
    db["pscis.pscis_points_all"].add_primary_key("stream_crossing_id")
    db["pscis.pscis_points_all"].create_index_geom()


def find_duplicates():
    """
    Note all pscis points within 10m of another pscis point
    """
    db["pscis.pscis_points_duplicates"].drop()
    sql = """CREATE TABLE pscis.pscis_points_duplicates AS
             SELECT
               a.stream_crossing_id AS id_1,
               s.stream_crossing_id AS id_2,
               s.dist_m
             FROM pscis.pscis_points_all As a
             CROSS JOIN LATERAL
                 (SELECT
                    stream_crossing_id,
                    ST_Distance(b.geom, a.geom) as dist_m
                   FROM pscis.pscis_points_all As b
                   WHERE a.stream_crossing_id != b.stream_crossing_id
                   AND ST_DWithin(a.geom, b.geom, 10)
                   ORDER BY b.geom <-> a.geom LIMIT 1) As s
             ORDER BY a.stream_crossing_id, dist_m;"""
    db.execute(sql)
    db["pscis.pscis_points_duplicates"].add_primary_key("stream_crossing_id")


def create_events(point_table="pscis.pscis_points_all"):
    """
    Create FWA blue_line_key events from PSCIS points
    """
    if point_table not in db.tables:
        return "Specified point table does not exist"
    # first, match points to model
    # generate table with all modeled crossings
    db.execute(queries["model_crossings_all"])
    # match pscis to the modeled crossings
    db.execute(db.build_query(queries["pscis_model_match_pts"],
                              {'pointTable': point_table}))
    # next, snap pscis points to streams
    db['fp_working.pscis_events'].drop()
    fwa = fwakit.FWA()
    fwa.create_events_from_points(point_table,
                                  "stream_crossing_id",
                                  "fp_working.pscis_stream_events",
                                  50)
    db["fp_working.pscis_stream_events"].create_index(["stream_crossing_id"])
    db.execute(queries["pscis_events_scored"])
    # finally, combine the two - retaining highest scored match
    db.execute(queries["pscis_events"])


def prune_events(threshold=5):
        """
        Even after QA that removed duplicate events <10 apart there are more issues.

        Find events that are so close together that they are unlikely to be
        valid distinct crossings (5m as default).
        Likely sources of problem are errors and unmapped streams, both of which
        we can safely discard from the primary event table.
        Decide which event to return by comparing assessment dates and distance
        from stream. Where dates are equivalent, presume that one record is on
        an unmapped stream and drop the record farther away. Where dates are not
        equivalent presume that there is an error or a re-assessment and drop the
        older record. These assumptions do not cover nearly all the possible
        problems but should resolve many.
        """
        sql = queries["prune_events"]
        # now, compare the events returned...
        # if dates are equivalent, keep point closer to stream
        # if dates are different, retain the more recent assessment
        drop_list = []
        for e in db.query(sql, (threshold,)):
            if (e["date_1"] == e["date_2"] and
               e["dist_1"] <= e["dist_2"]) or (e["date_1"] > e["date_2"]):
                drop_list.append(e["id_2"])
            elif (e["date_1"] == e["date_2"] and e["dist_1"] > e["dist_2"]) or (e["date_1"] < e["date_2"]):
                drop_list.append(e["id_1"])
        # put noted events into a different table so we can refer back easily
        db["fp_working.pscis_events_pruned"].drop()
        db["fp_working.pscis_events_pruning_residue"].drop()
        sql = """CREATE TABLE fp_working.pscis_events_pruning_residue AS
                 SELECT * FROM fp_working.pscis_events
                 WHERE stream_crossing_id in ({})
              """.format(",".join(["%s" for r in drop_list]))
        db.execute(sql, drop_list)
        sql = """CREATE TABLE fp_working.pscis_events_pruned AS
                 SELECT * FROM fp_working.pscis_events
                 WHERE stream_crossing_id not in ({})
              """.format(",".join(["%s" for r in drop_list]))
        db.execute(sql, drop_list)


def barrier_events():
    """
    Extract barriers from pruned event table
    """
    # The general event table might be useful for other queries, but for
    # fish passage, only interest is in barriers
    sql = """DROP TABLE IF EXISTS fp_working.pscis_events_barrier;
             CREATE TABLE fp_working.pscis_events_barrier AS
             SELECT
               e.*,
               p.current_pscis_status,
               p.current_barrier_result_code
             FROM fp_working.pscis_events_pruned e
             INNER JOIN pscis.pscis_points_all p
             ON e.stream_crossing_id = p.stream_crossing_id
             WHERE current_barrier_result_code in ('BARRIER','POTENTIAL');
             ALTER TABLE fp_working.pscis_events_barrier ADD PRIMARY KEY (stream_crossing_id);"""
    db.execute(sql)
