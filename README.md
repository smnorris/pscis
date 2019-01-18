# PSCIS

Python/Postgres tools for working with BC Provincial Stream Crossing Information System (PSCIS)

## Requirements

- Python 3
- PostgreSQL/PostGIS


## Installation

    git clone https://github.com/smnorris/pscis.git
    cd pscis
    pip install --user .


## Configuration

Create an environment variable `FWA_DB` and set it to the SQLAlchemy db url for your database. For example:

    MacOS/Linux etc: export FWA_DB=postgresql://postgres:postgres@localhost:5432/fwadb

    Windows: SET FWA_DB="postgresql://postgres:postgres@localhost:5432/fwadb"


## Usage

Get the latest PSCIS data and reference all points as events on the BC Freshwater Atlas Stream Network:

    pscis load

