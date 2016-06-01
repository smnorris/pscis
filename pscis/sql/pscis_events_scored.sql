-- Score pscis events created by snapping to streams
DROP TABLE IF EXISTS fp_working.pscis_events_scored;

CREATE TABLE fp_working.pscis_events_scored AS
SELECT DISTINCT ON (stream_crossing_id)
 *,
 distance_score + name_score + width_order_score AS total_score
FROM (
SELECT
 e.*,
 str.stream_order,
 str.gnis_name,
 a.stream_name,
 a.downstream_channel_width,
 CASE
    WHEN e.distance_to_stream < 10 THEN 100
    WHEN e.distance_to_stream >= 10 AND e.distance_to_stream < 20 THEN 75
    WHEN e.distance_to_stream >= 20 AND e.distance_to_stream < 50 THEN 25
    WHEN e.distance_to_stream >= 50 THEN 0
  END AS distance_score,
  CASE
    WHEN UPPER(a.stream_name) = UPPER(str.gnis_name) THEN 100
    ELSE 0
  END AS name_score,
  CASE
    WHEN a.downstream_channel_width = 0 THEN 0
    WHEN a.downstream_channel_width IS NULL THEN 0
    WHEN a.downstream_channel_width <> 0 AND a.downstream_channel_width / str.stream_order < .25 AND str.stream_order > 3 THEN -100
    WHEN a.downstream_channel_width <> 0 AND a.downstream_channel_width / str.stream_order < .25 AND str.stream_order <= 3 THEN 0
    WHEN a.downstream_channel_width <> 0 AND a.downstream_channel_width / str.stream_order >= .25 AND a.downstream_channel_width / str.stream_order < 3 THEN 0
    WHEN a.downstream_channel_width <> 0 AND a.downstream_channel_width / str.stream_order >= 3 AND str.stream_order >= 4 THEN 0
    WHEN a.downstream_channel_width <> 0 AND a.downstream_channel_width / str.stream_order >= 3 AND str.stream_order < 4 AND str.stream_order >= 2 THEN 0
    WHEN a.downstream_channel_width <> 0 AND a.downstream_channel_width / str.stream_order >= 3 AND str.stream_order < 2 THEN -75
  END AS width_order_score
FROM fp_working.pscis_stream_events e
INNER JOIN whse_basemapping.fwa_stream_networks_sp str
ON e.linear_feature_id = str.linear_feature_id
LEFT OUTER JOIN pscis.pscis_assessment_svw a ON e.stream_crossing_id = a.stream_crossing_id
) AS foo
ORDER BY stream_crossing_id, total_score desc;

CREATE INDEX pscis_events_scored_id ON fp_working.pscis_events_scored (stream_crossing_id);