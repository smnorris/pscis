DROP TABLE IF EXISTS whse_fish.pscis_events_barrier;

CREATE TABLE whse_fish.pscis_events_barrier AS
SELECT
  e.*,
  CASE
    WHEN hc.stream_crossing_id IS NOT NULL
    THEN 'HABITAT CONFIRMATION'
    ELSE p.current_pscis_status
  END AS pscis_status,
  p.current_barrier_result_code,
  -- include the source geometry just to make things simple
  p.geom
FROM whse_fish.pscis_events e
INNER JOIN whse_fish.pscis_points_all p
ON e.stream_crossing_id = p.stream_crossing_id
LEFT OUTER JOIN whse_fish.pscis_habitat_confirmation_svw hc
ON e.stream_crossing_id = hc.stream_crossing_id
WHERE p.current_barrier_result_code IN ('BARRIER', 'POTENTIAL');

ALTER TABLE whse_fish.pscis_events_barrier ADD PRIMARY KEY (stream_crossing_id);
