# simple commands for working with PSCIS data

import click

import pscis


@click.group()
def cli():
    pass


@click.command()
@click.option('--db_url', '-db', help='Database to load files to',
              envvar='FWA_DB')
def load(db_url):
    """Merge crossings into single table, create events, prune events
    """
    p = pscis.pscis(db_url)
    p.load_sources()
    p.merge_views()
    p.create_events()
    p.prune_events()


cli.add_command(load)
