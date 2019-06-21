# PSCIS

The [BC Provincial Stream Crossing Information System](https://www2.gov.bc.ca/gov/content/environment/natural-resource-stewardship/land-based-investment/investment-categories/fish-passage) (PSCIS) monitors fish passage on road-stream crossings throughout British Columbia. This repository downloads  PSCIS data to a Postgres db and links the crossings to the BC Freshwater Atlas - permitting upstream/downstream queries that enable  reporting on linear habitat potentially blocked by failed culverts.

## Requirements

- a PostgreSQL/PostGIS database (tested with 11.2/2.5.2)
- some tool for loading the PSCIS data to the database, such as https://github.com/bcgov/bcdata or https://github.com/smnorris/bcdata
- BC Freshwater Atlas data loaded and configured via [`fwapg`](https://github.com/smnorris/fwapg)
- BC Fish Passage habitat model data (available on request from the [Fish Passage Technical Working Group](https://www2.gov.bc.ca/gov/content/environment/plants-animals-ecosystems/fish/fish-passage)):
    + `fish_passage.road_stream_crossings_culverts`
    + `fish_passage.road_stream_crossings_other`
    + `fish_passage.fish_habitat`

## Installation

    $ git clone https://github.com/smnorris/pscis.git

## Data load

Using your preferred tool, load the PSCIS data to the `whse_fish` schema in your database. The supplied script uses the Python `bcdata` package:

    ./01_load.sh

## Usage

Run the sql scripts in order, using your preferred database client.
A control script is suppliced. The script assumes that your database connection paramaters are stored as environment variables (`$PGHOST`, `$PGUSER` etc)

    ./02_clean.sh

The sql scripts:

  - reference the points to the FWA stream network
  - remove duplicate locations/assessments as best as possible
  - attempt to link the PSICS points to fish passage modelled crossings (road-stream crossings)

Output tables are:

- `whse_fish.pscis_events`
- `whse_fish.pscis_events_barriers` (a subset of `pscis_events`, for convenience)
- `whse_fish.pscis_events_duplicates` (PSCIS crossings <10m apart, used for QA of the database)
