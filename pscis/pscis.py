import os
import subprocess

import click

import pgdata
from fwakit import fwa


@click.group()
def cli():
    pass


@cli.command()
@click.option('--db_url', '-db', help='Database to load files to',
              envvar='FWA_DB')
def load(db_url):
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


@cli.command()
@click.option('--db_url', '-db', help='Database to load files to',
              envvar='FWA_DB')
def clean(db_url):
    db = pgdata.connect(url=db_url)
    queries = pgdata.util.QueryDict(
        path=os.path.join(os.path.dirname(__file__), "sql")
    )

    # First, merge records from all whse views into a single table
    click.echo("running sql/pscis_load01_all_points")
    db.execute(queries["pscis_load01_all_points"])

    # Next, snap PSCIS points to streams, creating events_prelim1
    db["whse_fish.pscis_events_prelim1"].drop()
    click.echo("Referencing PSCIS points to stream network")
    fwa.reference_points(
        "whse_fish.pscis_points_all",
        "stream_crossing_id",
        "whse_fish.pscis_events_prelim1",
    )
    db["whse_fish.pscis_events_prelim1"].create_index(["stream_crossing_id"])

    # run queries in order
    for query in [
        "02_events_prelim2",
        "03_model_crossings_all",
        "04_model_match_pts",
        "05_events_prelim3",
        "06_events_prune",
        "07_events_barrier",
        "08_duplicates"
    ]:
        click.echo("Executing pscis_load{}".format(query))
        db.execute(queries["pscis_load{}".format(query)])

    # drop the working tables
    db["whse_fish.pscis_events_prelim1"].drop()
    db["whse_fish.pscis_events_prelim2"].drop()
    db["whse_fish.pscis_events_prelim3"].drop()
    db["whse_fish.pscis_model_match_pts"].drop()

