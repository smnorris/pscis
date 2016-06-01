#!/usr/bin/env bash
set -eu

# This script downloads the latest pscis dump and loads it all to postgres,
# in the pscis schema.
# *** ALL EXISTING DATA IN PSCIS SCHEMA WILL BE DELETED ***

# Database connection settings - edit as needed:
dbname=postgis
dbuser=postgres
dbhost=localhost
dbport=5432
psql="psql -q -h $dbhost -p $dbport -U $dbuser"

tmp=/Volumes/Data/Projects/env/fish_passage/pscis/tmp

# download pscis dump and unzip
#echo "Downloading PSCIS data..."
#wget --user fishpassage \
#     --password Culv3rt \
#     --trust-server-names \
#     -qNP "$tmp" http://www.hillcrestgeo.ca/fishpassage/pscis/pscis_bcgw.zip
unzip -qjun -d "$tmp" "$tmp/pscis_bcgw.zip"

# wipe pscis schema
echo "Dropping all existing PSCIS tables"
$psql --dbname=$dbname --quiet --command="DROP SCHEMA IF EXISTS pscis CASCADE"
$psql --dbname=$dbname --quiet --command="CREATE SCHEMA pscis"

# send .csv files to postgres
echo "Loading PSCIS .csv files"
# csvkit/csvsql doesn't handle weird dates properly
# remove expiration of 9999 from pscis_crossing_subtype_codes.csv
sed -i '' 's/,9999-12-31 00:00:00,/,,/g' $tmp/pscis_crossing_subtype_codes.csv
csv2pg -s pscis -e iso-8859-1 $tmp/pscis*csv

# send geojson files to postgres, BC Albers
echo "Loading PSCIS spatial files"
for table in $tmp/pscis*.json; do
    echo $table
    tablename=`basename $table .json`
    PGCLIENTENCODING=LATIN1 ogr2ogr \
        -f PostgreSQL \
        -s_srs EPSG:4326 \
        -t_srs EPSG:3005 \
        PG:"dbname=$dbname user=$dbuser host=$dbhost port=$dbport" \
        -lco GEOMETRY_NAME=geom \
        -lco OVERWRITE=YES \
        -lco DIM=2 \
        -lco SCHEMA=pscis \
        -nlt GEOMETRY \
        -nln $tablename \
        $table

    # drop the ogr2ogr created key
    $psql --dbname=$dbname --quiet --command="ALTER TABLE pscis.$tablename DROP COLUMN IF EXISTS ogc_fid"
done

# could add primary keys here
#for table in $tmp/pscis*.*; do
#    if $table not in ["pscis_crossing_type_xref", "pscis_stream_cross_loc_point"]:
#    column = db.get_column_names(schema+"."+t)[0]
#if t == "pscis_stream_cross_loc_point":
#    column = "stream_crossing_id"
#if t == "pscis_crossing_type_xref":
#    column = ("crossing_type_code, crossing_subtype_code")
#if not db.get_primary_key(schema+"."+t):
#    db.execute("""ALTER TABLE {s}.{t}
#                  ADD PRIMARY KEY ({c});


echo "DONE - latest PSCIS data are loaded to postgis db"