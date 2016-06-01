DROP TABLE IF EXISTS fp_working.pscis_events;

CREATE TABLE fp_working.pscis_events AS
SELECT DISTINCT ON (stream_crossing_id) * FROM
(SELECT
  stream_crossing_id,
  model_crossing_id,
  dist_m AS distance_to_stream,
  fwa_watershed_code,
  local_watershed_code,
  blue_line_key,
  downstream_route_measure,
  watershed_group_code,
  total_score AS score
FROM fp_working.pscis_model_match_pts
UNION ALL
SELECT
  stream_crossing_id,
  NULL::INT AS model_crossing_id,
  distance_to_stream,
  fwa_watershed_code,
  local_watershed_code,
  blue_line_key,
  downstream_route_measure,
  watershed_group_code,
  total_score AS score
FROM fp_working.pscis_events_scored) AS foo
ORDER BY stream_crossing_id, score desc;

ALTER TABLE fp_working.pscis_events ADD PRIMARY KEY (stream_crossing_id);
