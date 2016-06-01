pscis
======

Tools for working with BC Provincial Stream Crossing Information System (PSCIS)


Usage
-------------------------

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