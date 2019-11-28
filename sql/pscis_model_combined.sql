-- First, figure out which modelled crossings NOT to insert, as they are
-- covered by PSCIS crossings

-- find all modelled crossings within 100m of a PSCIS crossing
DROP TABLE IF EXISTS fish_passage.pscis_model_dups;
CREATE TABLE fish_passage.pscis_model_dups AS

WITH candidates AS
(SELECT
  m.crossing_id,
  m.blue_line_key as blkey_m,
  m.downstream_route_measure as meas_m,
  p.stream_crossing_id,
  p.blue_line_key as blkey_p,
  p.downstream_route_measure as meas_p
FROM fish_passage.modelled_crossings_closed_bottom m
INNER JOIN whse_fish.pscis_events_barrier p
ON ST_DWithin(m.geom, p.geom, 100)
WHERE p.model_crossing_id IS NULL
)

-- From above set, select the modelled crossing with lowest
-- instream distance to a pscis crossing. Those that are
-- <25m instream from a PSCIS crossing are likely to be a PSCIS crossing
SELECT DISTINCT ON (stream_crossing_id)
crossing_id as model_crossing_id,
stream_crossing_id as pscis_stream_crossing_id,
length_instream
FROM (
    SELECT DISTINCT ON (crossing_id)
     crossing_id,
     stream_crossing_id,
     fwa_lengthinstream(
     blkey_p::integer,
     meas_p,
     blkey_m,
     meas_m) as length_instream
    FROM candidates
    ORDER BY crossing_id, stream_crossing_id, fwa_lengthinstream(
    blkey_p::integer,
    meas_p,
    blkey_m,
    meas_m)
) as x
WHERE length_instream is not null
AND length_instream < 25
ORDER BY stream_crossing_id, length_instream;


DROP TABLE IF EXISTS fish_passage.pscis_model_combined;

CREATE TABLE fish_passage.pscis_model_combined
(
pscis_model_combined_id serial primary key,
pscis_stream_crossing_id integer,
model_crossing_id integer,
linear_feature_id bigint,
blue_line_key integer,
downstream_route_measure float,
wscode_ltree ltree,
localcode_ltree ltree,
fwa_watershed_code text,
local_watershed_code text,
watershed_group_code text,
pscis_status text,
geom geometry(POINT, 3005));

INSERT INTO fish_passage.pscis_model_combined
(pscis_stream_crossing_id,
model_crossing_id,
linear_feature_id,
blue_line_key,
downstream_route_measure,
wscode_ltree,
localcode_ltree,
fwa_watershed_code,
local_watershed_code,
watershed_group_code,
pscis_status,
geom)
SELECT
stream_crossing_id as pscis_stream_crossing_id,
model_crossing_id,
linear_feature_id,
blue_line_key,
downstream_route_measure,
wscode_ltree,
localcode_ltree,
fwa_watershed_code,
local_watershed_code,
watershed_group_code,
pscis_status,
geom
FROM whse_fish.pscis_events_barrier;

INSERT INTO fish_passage.pscis_model_combined
(
    model_crossing_id,
    linear_feature_id,
    blue_line_key,
    downstream_route_measure,
    wscode_ltree,
    localcode_ltree,
    fwa_watershed_code,
    local_watershed_code,
    watershed_group_code,
    geom)
SELECT
crossing_id as model_crossing_id,
linear_feature_id,
blue_line_key,
downstream_route_measure,
wscode_ltree,
localcode_ltree,
fwa_watershed_code,
local_watershed_code,
watershed_group_code,
geom
FROM fish_passage.modelled_crossings_closed_bottom
WHERE crossing_id NOT IN
(
    SELECT DISTINCT model_crossing_id
    FROM fish_passage.pscis_model_combined WHERE model_crossing_id is NOT NULL
    UNION ALL
    SELECT model_crossing_id
    FROM fish_passage.pscis_model_dups
)
AND fish_habitat != 'NON FISH HABITAT';

-- create indexes
CREATE UNIQUE INDEX ON fish_passage.pscis_model_combined (pscis_stream_crossing_id);
CREATE UNIQUE INDEX ON fish_passage.pscis_model_combined (model_crossing_id);
CREATE INDEX ON fish_passage.pscis_model_combined (fwa_watershed_code);
CREATE INDEX ON fish_passage.pscis_model_combined (local_watershed_code);
CREATE INDEX ON fish_passage.pscis_model_combined USING GIST (wscode_ltree);
CREATE INDEX ON fish_passage.pscis_model_combined USING BTREE (wscode_ltree);
CREATE INDEX ON fish_passage.pscis_model_combined USING GIST (localcode_ltree);
CREATE INDEX ON fish_passage.pscis_model_combined USING BTREE (localcode_ltree);