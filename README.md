# PSCIS

Python/Postgres tools for working with BC Provincial Stream Crossing Information System (PSCIS)

## Requirements

- Python 3
- a PostgreSQL/PostGIS database with BC Freshwater Atlas data loaded and configured via [`fwakit`](https://github.com/smnorris/fwakit)


## Installation

    git clone https://github.com/smnorris/pscis.git
    cd pscis
    pip install --user .


## Usage

Several Python functions are available, but the most likely usage is likely via the `pscis` commandline tool. To get the latest PSCIS data and reference all points as events on the BC Freshwater Atlas Stream Network:

    $ pscis load --help
    Usage: pscis load [OPTIONS]

      Merge crossings into single table, create events, prune events

    Options:
      -db, --db_url TEXT  Database to load files to
      --help              Show this message and exit.

## Optional Configuration

Create an environment variable `FWA_DB` and set it to the SQLAlchemy db url for your database. For example:

    MacOS/Linux etc: export FWA_DB=postgresql://postgres:postgres@localhost:5432/fwadb

    Windows: SET FWA_DB="postgresql://postgres:postgres@localhost:5432/fwadb"
