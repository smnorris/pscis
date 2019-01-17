# PSCIS

Tools for working with BC Provincial Stream Crossing Information System (PSCIS)

## Requirements

- Python 3
- PostgreSQL/PostGIS


## Installation

    git clone <pscis repo>
    cd pscis
    pip install --user .

## Configuration

Create an environment variable FWA_DB and set it to the SQLAlchemy db url for your database. For example:

MacOS/Linux etc: export FWA_DB=postgresql://postgres:postgres@localhost:5432/fwadb

Windows: SET FWA_DB="postgresql://postgres:postgres@localhost:5432/fwadb"


1. Get a full extract of the latest data from source.
   On Province of BC GTS server:
    - navigate to `\\LEVEL\S40006\ESD\EI_Shared\Fish\Culvert Fish Passage\HillcrestWorkArea\PSCIS\scripts`
    - shift+right click then select `Open Command Window Here`
    - Run the dump script: `python dump_pscis.py`
   Edit the script as necessary if a different server is to be used for file
   transfer.

   OR run `dump_pscis.bat`, zip up resulting files and manually copy to local system

2. Edit `pscis/config.json` as necessary (ie, if a different server is to be used
   for file transfer). Load data to local postgres database:
   `pscis load`.

3. Apply any necessary updates/fixes to the loaded data (updates/fixes that
   haven't yet made it to BCGW):
   `pscis update`

4. Produce standard culvert fish habitat report for all pscis crossings:
   `pcsis fp_report`