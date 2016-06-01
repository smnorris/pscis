# simple commands for working with PSCIS data
import subprocess
import os

import click

import pscis


@click.group()
def cli():
    pass


@click.command()
def load():
    """
    Load latest dumped PSCIS data to local database
    This is simply a shortcut to the shell script.
    """
    script = os.path.join(pscis.__path__[0], 'scripts', 'load_pscis.sh')
    subprocess.call([script])
    # apply any updates that are in the hopper
    #pscis.apply_updates()
    #click.echo("PSCIS updates in /pscis/sql/updates applied")


@click.command()
def update():
    """
    Updates and fixes can take some time to reach BCGW.
    Apply ready fixes to dumped data
    """
    pscis.apply_updates()
    click.echo("PSCIS updates in /pscis/sql/updates applied")


cli.add_command(load)
cli.add_command(update)
