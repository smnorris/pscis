# PSCIS

The [BC Provincial Stream Crossing Information System](https://www2.gov.bc.ca/gov/content/environment/natural-resource-stewardship/land-based-investment/investment-categories/fish-passage) (PSCIS) monitors fish passage on road-stream crossings throughout British Columbia. This repository downloads  PSCIS data to a Postgres db and links the crossings to the BC Freshwater Atlas - permitting upstream/downstream queries that enable  reporting on linear habitat potentially blocked by failed culverts.

## Requirements

- a PostgreSQL/PostGIS database (tested with 12.1/3.0.1)
- [bcdata](https://github.com/smnorris/bcdata)
- BC Freshwater Atlas data loaded and configured via [`fwapg`](https://github.com/smnorris/fwapg)
- BC Fish Passage potential habitat model (available on request from the [Fish Passage Technical Working Group](https://www2.gov.bc.ca/gov/content/environment/plants-animals-ecosystems/fish/fish-passage)):
    + `fish_passage.modelled_crossings_closed_bottom`
    + `fish_passage.modelled_crossings_open_bottom`


## Installation / Setup

Download the scripts:

    $ git clone https://github.com/smnorris/pscis.git

Once the FWA database is set up via `fwapg` no further setup should be needed.
The scripts assume that your database connection paramaters are stored as environment variables (`$PGHOST`, `$PGUSER` etc).

## Data load

Load the [PSCIS tables](https://catalogue.data.gov.bc.ca/dataset?q=pscis) to the `whse_fish` schema:

    ./01_download.sh

Load the modelled crossing tables (closed bottom/culverts and open bottom/bridges) to the `fish_passage` schema. For example:

```
psql -c "CREATE SCHEMA IF NOT EXISTS fish_passage"

ogr2ogr \
  -f PostgreSQL \
  PG:host=localhost port=5432 user=postgres dbname=postgis password=postgres \
  -lco SCHEMA=fish_passage \
  -lco GEOMETRY_NAME=geom \
  fish_passage_points.gpkg \
  modelled_crossings_closed_bottom

ogr2ogr \
  -f PostgreSQL \
  PG:host=localhost port=5432 user=postgres dbname=postgis password=postgres \
  -lco SCHEMA=fish_passage \
  -lco GEOMETRY_NAME=geom \
  fish_passage_points.gpkg \
  modelled_crossings_open_bottom
```

## Usage

Run the sql scripts in order:

    ./02_clean.sh

## Method

The sql scripts / output tables are:

#### `01_pscis_points_all`

Combines the four WHSE_FISH.PSCIS views (assessments, confirmations, designs, remediations) into a single table with unique crossings.

#### `02_pscis_events_prelim1`

Reference `pscis_points_all` to the closest stream(s) in FWA stream network within 100m. A crossing will often be within 100m of more than one stream, all results are kept in this preliminary step.

#### `03_pscis_events_prelim2`

From `events_prelim1`, attempt to find the best matching of the pscis point to stream using a combination of:

- distance of PSCIS point to stream
- similarity of PSCIS `stream_name` column to the `gnis_name` of the stream
- the relationship of PSCIS `downstream_channel_width` to the `stream_order` of the FWA stream - if a very wide channel is matched to a low order stream, it is probably not the correct match

#### `04_modelled_crossings_all`

Combine all modelled crossings (`fish_passage.modelled_crossings_closed_bottom`, `fish_passage.modelled_crossings_open_bottom`) into a single table containing all modelled road crossings.


#### `05_pscis_model_match_pts`

Match PSCIS points to the modelled crossings where possible. Similar to the matching of PSCIS crossings to streams noted above, the script attempts to find the best match based on:

- distance of PSCIS point to modelled crossing point
- matching the crossing types (if PSCIS `crossing_subtype_code` indicates the crossing is a bridge and the model predicts a bridge, the points are probably a match.
- as above, check the relationship of PSCIS `downstream_channel_width` to the `stream_order` of the FWA stream

#### `06_pscis_events_prelim3`

Combine the results from 1 and 2 above into a single table that is our best guess of which stream the PSCIS crossing should be associdated with. Because we do not want to overly shift the field GPS coordinates in PSCIS, we are very conservative with matching to modelled points and will primarily snap to the closest point on the stream rather than a modelled crossing farther away.

#### `07_pscis_events`

Remove locations from `pscis_events_prelim3` which are obvious duplicates (instream position is within 5m). The PSCIS feature retained is based on (in order of priority):
    - status (1 REMEDIATED, 2 DESIGN, 3 CONFIRMATION, 4 ASSESSED)
    - most recently assessed
    - closest source point to stream

#### `08_pscis_events_barrier`

From `pscis_events`, extract only barrier crossings - the primary output table of interest for further fish passage analysis / prioritization work

#### `09_pscis_points_duplicates`

For general QA of the PSCIS database, create a report of all source crossing locations that are within 10m of another crossing location.

#### `10_pscis_model_combined`

DRAFT - a first rough cut at combining the PSCIS data and modelled road-stream crossings into a single table for easy upstream / downstream barrier analysis.

To go further with this, we need to determine how to structure and work with our barrier analysis database:
 - include non-barrier PSCIS structures
 - include modelled OBS?
 - include barriers other than road crossings? (Dams, natural barriers etc)

#### `11_cleanup`
Clean up, deleting temporary tables created by above steps.
