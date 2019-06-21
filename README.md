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

## Method

The sql scripts:

1. Combine the various PSCIS source tables into a single table

2. Reference the PSCIS points to the closest stream(s) in FWA stream network  within 100m. A crossing will often be within 100m of more than one stream, all results are kept in this preliminary step

3. Based on above, attempting to find the best matched stream using a combination of:
    - distance of PSCIS point to stream
    - similarity of PSCIS `stream_name` column to the `gnis_name` of the stream
    - the relationship of PSCIS `downstream_channel_width` to the `stream_order` of the FWA stream - if a very wide channel is matched to a low order stream, it is probably not the correct match

4. Combines all modelled crossings into a single table containing points expected to be both open and closed bottom structures

5. Match the PSCIS points to the modelled crossings where possible. Similar to the process above, the script attempts to find the best match based on:
    - distance of PSCIS point to modelled crossing point
    - matching the crossing types (if PSCIS `crossing_subtype_code` indicates the crossing is a bridge and the model predicts a bridge, the points are probably a match.
    - as above, check the relationship of PSCIS `downstream_channel_width` to the `stream_order` of the FWA stream

6. Combine the results from 1 and 2 above into a single table that is our best guess of which stream the PSCIS crossing should be associdated with

7. Remove locations from the output which are obvious duplicates (instream position is within 5m). The PSCIS feature retained is based on (in order of priority):
    - status (1 REMEDIATED, 2 DESIGN, 3 ASSESSED)
    - most recently assessed
    - closest source point to stream

    Output table is `whse_fish.pscis_events`

8. From the output, extract PSCIS crossings that are barriers to create the primary output table used for further fish passage analysis / prioritization work (`whse_fish.pscis_events_barriers`)

9. For general QA of the PSCIS database, create a report of all source crossing locations that are within 10m of another crossing location (`whse_fish.pscis_events_duplicates`)

10. Clean up, deleting temporary tables created by above steps.
