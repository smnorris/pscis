-- Join pscis points to nearest 5 modelled xings within 100m,
-- returning only a single match by scoring the results based on:
--   - distance
--   - structure (both are bridges),
--   - stream name (exact match)
--   - downstream width vs order (outliers get negative score)

DROP TABLE IF EXISTS fp_working.pscis_model_match_pts;

CREATE TABLE fp_working.pscis_model_match_pts AS
-- add assessment attributes required for scoring to pscis_points_all
WITH pscis AS (
SELECT
 p.*,
 a.stream_name,
 a.crossing_subtype_code,
 a.downstream_channel_width
FROM $pointTable p
LEFT OUTER JOIN pscis.pscis_assessment_svw a
ON p.stream_crossing_id = a.stream_crossing_id)

-- Return only the max scoring result by using DISTINCT ON (stream_crossing_id) and sorting on score
SELECT DISTINCT ON (stream_crossing_id)
  stream_crossing_id,
  closest_modelled_xing AS model_crossing_id,
  dist_m,
  fwa_watershed_code,
  local_watershed_code,
  blue_line_key,
  downstream_route_measure,
  watershed_group_code,
  distance_score,
  name_score,
  bridge_score,
  width_order_score,
  (distance_score + name_score + bridge_score + width_order_score) AS total_score
FROM (
SELECT
  a.stream_crossing_id,
  m.crossing_id AS closest_modelled_xing,
  m.dist_m,
  m.fwa_watershed_code,
  m.local_watershed_code,
  m.blue_line_key,
  m.downstream_route_measure,
  m.watershed_group_code,
  -- high scores for nearby points, low for farther away
  CASE
    WHEN m.dist_m < 10 THEN 100
    WHEN m.dist_m >= 10 AND m.dist_m < 20 THEN 75
    WHEN m.dist_m >= 20 AND m.dist_m < 50 THEN 25
    WHEN m.dist_m >= 50 THEN 0
  END AS distance_score,
  -- exact name matches get a very high score
  CASE
    WHEN UPPER(a.stream_name) = UPPER(m.gnis_name) THEN 100
    ELSE 0
  END AS name_score,
  -- if both structures are bridges they are probably a match
  CASE
    WHEN a.crossing_subtype_code = 'BRIDGE' AND m.model_xing_type = 'bridge' THEN 75
    ELSE 0
  END AS bridge_score,
  -- stream width to stream order relationship doesn't increase scores as it
  -- doesn't necessarily indicate a good match, it just reduces scores for outliers
  -- the scoring is pretty aribitrary though, could probably be improved with more
  -- investigation
  CASE
    WHEN a.downstream_channel_width = 0 THEN 0
    WHEN a.downstream_channel_width IS NULL THEN 0
    WHEN a.downstream_channel_width <> 0 AND a.downstream_channel_width / m.stream_order < .25 AND m.stream_order > 3 THEN -100
    WHEN a.downstream_channel_width <> 0 AND a.downstream_channel_width / m.stream_order < .25 AND m.stream_order <= 3 THEN 0
    WHEN a.downstream_channel_width <> 0 AND a.downstream_channel_width / m.stream_order >= .25 AND a.downstream_channel_width / m.stream_order < 3 THEN 0
    WHEN a.downstream_channel_width <> 0 AND a.downstream_channel_width / m.stream_order >= 3 AND m.stream_order >= 4 THEN 0
    WHEN a.downstream_channel_width <> 0 AND a.downstream_channel_width / m.stream_order >= 3 AND m.stream_order < 4 AND m.stream_order >= 2 THEN 0
    WHEN a.downstream_channel_width <> 0 AND a.downstream_channel_width / m.stream_order >= 3 AND m.stream_order < 2 THEN -75
  END AS width_order_score
--FROM pscis.pscis_assessment_svw AS a
FROM pscis AS a
-- find nearest neighbours
CROSS JOIN LATERAL
( SELECT crossing_id, fwa_watershed_code, local_watershed_code, blue_line_key, downstream_route_measure, watershed_group_code, stream_order, gnis_name, model_xing_type, ST_Distance(b.geom, a.geom) as dist_m
    FROM fp_working.model_crossings_all AS b
ORDER BY b.geom <-> a.geom
   LIMIT 5) AS m
WHERE dist_m < 100
ORDER BY stream_crossing_id) AS foo
-- remove zero total scores from consideration, they likely aren't a match
WHERE (distance_score + name_score + bridge_score + width_order_score) > 0
ORDER BY stream_crossing_id, total_score desc;

-- create idx
ALTER TABLE fp_working.pscis_model_match_pts ADD PRIMARY KEY (stream_crossing_id);
CREATE INDEX pscis_model_match_xingid ON fp_working.pscis_model_match_pts (model_crossing_id);