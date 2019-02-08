# CLI for working with PSCIS data
# (more can be added if model is ported to Python 3)

import click
import pscis


@click.group()
def cli():
    pass


@click.command()
@click.option('--db_url', '-db', help='Database to load files to',
              envvar='FWA_DB')
def load(db_url):
    """Load PSCIS to local db, create events, clean.
    """
    pscis.load(db_url)


cli.add_command(load)
