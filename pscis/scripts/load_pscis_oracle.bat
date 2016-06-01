ogrinfo -ro -so OCI:"pscis/pscis@(DESCRIPTION =(ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))(CONNECT_DATA = (SERVER = DEDICATED)(SERVICE_NAME = orcl))):pscis.pscis_stream_cross_loc_point"

ogr2ogr -f OCI OCI:"system/orcl@(DESCRIPTION = (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))(CONNECT_DATA = (SERVER = DEDICATED)(SERVICE_NAME = orcl)))"




-- drop data
DELETE FROM pscis_attachments;
DELETE FROM pscis_remediation_results;
DELETE FROM pscis_remediation_design_props;
DELETE FROM pscis_habitat_species_xref;
DELETE FROM pscis_habitat_confirmations;
DELETE FROM pscis_crossing_assessments;
DELETE FROM pscis_projects;
DELETE FROM pscis_submissions;
DELETE FROM pscis_structures;
DELETE FROM pscis_stream_cross_loc_point;

-- load fresh data, in reverse order
ogr2ogr -f OCI OCI:"system/orcl@(DESCRIPTION = (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))(CONNECT_DATA = (SERVER = DEDICATED)(SERVICE_NAME = orcl)))"
