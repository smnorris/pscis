DROP TABLE IF EXISTS whse_fish.pscis_events_barrier;

CREATE TABLE whse_fish.pscis_events_barrier AS
SELECT
  e.*,
  p.current_pscis_status,
  p.current_barrier_result_code
FROM whse_fish.pscis_events e
INNER JOIN whse_fish.pscis_points_all p
ON e.stream_crossing_id = p.stream_crossing_id
WHERE current_barrier_result_code IN ('BARRIER', 'POTENTIAL');

ALTER TABLE whse_fish.pscis_events_barrier ADD PRIMARY KEY (stream_crossing_id);