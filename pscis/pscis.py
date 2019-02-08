import os
import subprocess

import pgdata
from fwakit import fwa


def load(db_url):
    db = pgdata.connect(url=db_url)
    queries = pgdata.util.QueryDict(
        path=os.path.join(os.path.dirname(__file__), "sql")
    )

    source_tables = [
        "WHSE_FISH.PSCIS_ASSESSMENT_SVW",
        "WHSE_FISH.PSCIS_DESIGN_PROPOSAL_SVW",
        "WHSE_FISH.PSCIS_HABITAT_CONFIRMATION_SVW",
        "WHSE_FISH.PSCIS_REMEDIATION_SVW",
    ]

    for table in source_tables:
        subprocess.call(
            "bcdata bc2pg {} --db_url {}".format(table, db_url), shell=True
        )
    db.execute(queries["pscis_points_all"])

    if "whse_fish.pscis_points_all" not in db.tables:
        return "Input table whse_fish.pscis_points_all does not exist"

    # First, snap pscis points to streams, creating events_prelim1
    db["whse_fish.pscis_events_prelim1"].drop()
    fwa.reference_points(
        "whse_fish.pscis_points_all",
        "stream_crossing_id",
        "whse_fish.pscis_events_prelim1",
    )
    db["whse_fish.pscis_events_prelim1"].create_index(["stream_crossing_id"])

    # Score the snapping results, creating events_prelim2
    # (scoring attemts to identify crossings which have been matched
    # to the wrong stream, based on stream name, distance, channel width)
    db.execute(queries["pscis_events_prelim2"])

    # Now, we want to match PSCIS points to modelled crossing points.
    # To do this, we need a table holding all modeled crossings
    # (combine culverts and bridges)
    db.execute(queries["model_create_crossings_all"])

    # Now match pscis to the combined modeled crossings
    db.execute(queries["pscis_model_match_pts"])

    # Combine the two sources, matched to modelled crossings and
    # matched to streams. Retaining only the highest scored match
    db.execute(queries["pscis_events_prelim3"])

    # Some duplicates are present in the data, remove crossings
    # <5m of another, on the same stream
    db.execute(queries["pscis_events_prune"])

    # Finally, general event table is useful, but for fish passage
    # reporting, we are mostly interested in barriers
    db.execute(queries["pscis_events_barrier"])
