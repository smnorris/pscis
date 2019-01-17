import os
import subprocess

import click

import pgdata
from fwakit import fwa


class pscis(object):
    def __init__(self, db_url):
        self.db_url = db_url
        self.db = pgdata.connect(url=db_url)
        self.queries = pgdata.util.QueryDict(
            path=os.path.join(os.path.dirname(__file__), "sql")
        )
        self.source_tables = [
            "WHSE_FISH.PSCIS_ASSESSMENT_SVW",
            "WHSE_FISH.PSCIS_DESIGN_PROPOSAL_SVW",
            "WHSE_FISH.PSCIS_HABITAT_CONFIRMATION_SVW",
            "WHSE_FISH.PSCIS_REMEDIATION_SVW",
        ]

    def load_sources(self):
        for table in self.source_tables:
            subprocess.call(
                "bcdata bc2pg {} --db_url {}".format(table, self.db_url), shell=True
            )

    def merge_views(self):
        """Merge assessments, confirmations, designs, remediations
        """
        click.echo("PSCIS - merging data into a single table")

        if "whse_fish.pscis_points_all" in self.db.tables:
            self.db["whse_fish.pscis_points_all"].drop()
        self.db.execute(self.queries["pscis_points_all"])
        # add indexes
        self.db["whse_fish.pscis_points_all"].add_primary_key("stream_crossing_id")
        self.db["whse_fish.pscis_points_all"].create_index_geom()

    def find_duplicates(self):
        """Note all pscis points within 10m of another pscis point
        """
        click.echo("PSCIS - noting points within 10m of another PSCIS point")
        self.db["whse_fish.pscis_points_duplicates"].drop()
        sql = """CREATE TABLE whse_fish.pscis_points_duplicates AS
                 SELECT
                   a.stream_crossing_id AS id_1,
                   s.stream_crossing_id AS id_2,
                   s.dist_m
                 FROM whse_fish.pscis_points_all As a
                 CROSS JOIN LATERAL
                     (SELECT
                        stream_crossing_id,
                        ST_Distance(b.geom, a.geom) as dist_m
                       FROM whse_fish.pscis_points_all As b
                       WHERE a.stream_crossing_id != b.stream_crossing_id
                       AND ST_DWithin(a.geom, b.geom, 10)
                       ORDER BY b.geom <-> a.geom LIMIT 1) As s
                 ORDER BY a.stream_crossing_id, dist_m;"""
        self.db.execute(sql)
        self.db["whse_fish.pscis_points_duplicates"].add_primary_key(
            "stream_crossing_id"
        )

    def create_events(self):
        """Create FWA blue_line_key events from PSCIS points
        """
        click.echo("PSCIS - creating FWA events")
        if "whse_fish.pscis_points_all" not in self.db.tables:
            return "Input table whse_fish.pscis_points_all does not exist"

        # first, match points to model
        # generate table with all modeled crossings
        self.db.execute(self.queries["model_create_crossings_all"])

        # match pscis to the modeled crossings
        self.db.execute(self.queries["pscis_model_match_pts"])

        # next, snap pscis points to streams
        self.db["whse_fish.pscis_stream_events"].drop()
        fwa.reference_points(
            "whse_fish.pscis_points_all",
            "stream_crossing_id",
            "whse_fish.pscis_stream_events",
        )

        self.db["whse_fish.pscis_stream_events"].create_index(["stream_crossing_id"])
        self.db.execute(self.queries["pscis_events_scored"])

        # finally, combine the two - retaining highest scored match
        self.db.execute(self.queries["pscis_events"])

    def prune_events(self, threshold=5):
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
        click.echo("PSCIS - pruning events")
        sql = self.queries["pscis_prune_events"]
        # now, compare the events returned...
        # if dates are equivalent, keep point closer to stream
        # if dates are different, retain the more recent assessment
        drop_list = []
        for e in self.db.query(sql, (threshold,)):
            if (e["date_1"] == e["date_2"] and e["dist_1"] <= e["dist_2"]) or (
                e["date_1"] > e["date_2"]
            ):
                drop_list.append(e["id_2"])
            elif (e["date_1"] == e["date_2"] and e["dist_1"] > e["dist_2"]) or (
                e["date_1"] < e["date_2"]
            ):
                drop_list.append(e["id_1"])
        # put noted events into a different table so we can refer back easily
        self.db["whse_fish.pscis_events_pruned"].drop()
        self.db["whse_fish.pscis_events_pruning_residue"].drop()
        sql = """CREATE TABLE whse_fish.pscis_events_pruning_residue AS
                     SELECT * FROM whse_fish.pscis_events
                     WHERE stream_crossing_id in ({})
                  """.format(
            ",".join(["%s" for r in drop_list])
        )
        self.db.execute(sql, drop_list)
        sql = """CREATE TABLE whse_fish.pscis_events_pruned AS
                     SELECT * FROM whse_fish.pscis_events
                     WHERE stream_crossing_id not in ({})
                  """.format(
            ",".join(["%s" for r in drop_list])
        )
        self.db.execute(sql, drop_list)

    def barrier_events(self):
        """
        Extract barriers from pruned event table
        """
        # The general event table might be useful for other queries, but for
        # fish passage, only interest is in barriers
        click.echo("Extracting BARRIER PSCIS events to pscis_events_barrier")
        sql = """DROP TABLE IF EXISTS whse_fish.pscis_events_barrier;
                 CREATE TABLE whse_fish.pscis_events_barrier AS
                 SELECT
                   e.*,
                   p.current_pscis_status,
                   p.current_barrier_result_code
                 FROM whse_fish.pscis_events_pruned e
                 INNER JOIN whse_fish.pscis_points_all p
                 ON e.stream_crossing_id = p.stream_crossing_id
                 WHERE current_barrier_result_code in ('BARRIER','POTENTIAL');
                 ALTER TABLE whse_fish.pscis_events_barrier ADD PRIMARY KEY (stream_crossing_id);"""
        self.db.execute(sql)
