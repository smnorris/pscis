# PSCIS

Tools for working with [BC Provincial Stream Crossing Information System](https://www2.gov.bc.ca/gov/content/environment/natural-resource-stewardship/land-based-investment/investment-categories/fish-passage) (PSCIS).

The PSCIS system monitors fish passage on road-stream crossings throughout the province. This repository downloads the PSCIS data to a Postgres db and links the crossings to the BC Freshwater Atlas - permitting upstream/downstream queries that enable  reporting on linear habitat potentially blocked by failed culverts.

## Requirements

- Python 3
- a PostgreSQL/PostGIS database (tested with 10.6/2.5)
- BC Freshwater Atlas data loaded and configured via [`fwakit`](https://github.com/smnorris/fwakit)
- BC Fish Passage habitat model data:
    + `fish_passage.road_stream_crossings_culverts`
    + `fish_passage.road_stream_crossings_other`
    + `fish_passage.fish_habitat`

## Installation

    $ git clone https://github.com/smnorris/pscis.git
    $ pip install -r requirements.txt

For easier usage, create an environment variable `FWA_DB` and set it to the SQLAlchemy db url for your database. For example:

MacOS/Linux etc:

    export FWA_DB=postgresql://postgres:postgres@localhost:5432/fwadb

Windows:

    SET FWA_DB="postgresql://postgres:postgres@localhost:5432/fwadb"

## Usage

To load and prep data:

    $ pscis load --db_url postgresql://postgres:postgres@localhost:5432/fwadb

Or, if `FWA_DB` variable is set,

    $ pscis load

This script:

- loads PSCIS data from DataBC to local db in `whse_fish` schema
- references PSCIS sites to the FWA stream network
- links PSCIS sites to Fish Passage modelled crossings where possible
- cleans duplicate PSCIS crossings (<5m apart on the same stream)
- creates output tables for further analysis:
    + `whse_fish.pscis_events`
    + `whse_fish.pscis_events_barriers`
