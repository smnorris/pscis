-- The general event table is useful, but for fish passage
-- reporting/prioritization, we are mostly interested in barriers

DROP TABLE IF EXISTS whse_fish.pscis_events_barrier;

CREATE TABLE whse_fish.pscis_events_barrier AS
SELECT
  e.*,
  CASE
    WHEN hc.stream_crossing_id IS NOT NULL
    THEN 'HABITAT CONFIRMATION'
    ELSE p.current_pscis_status
  END AS pscis_status,
  p.current_barrier_result_code
FROM whse_fish.pscis_events e
INNER JOIN whse_fish.pscis_points_all p
ON e.stream_crossing_id = p.stream_crossing_id
LEFT OUTER JOIN whse_fish.pscis_habitat_confirmation_svw hc
ON e.stream_crossing_id = hc.stream_crossing_id
WHERE p.current_barrier_result_code IN ('BARRIER', 'POTENTIAL');

ALTER TABLE whse_fish.pscis_events_barrier ADD PRIMARY KEY (stream_crossing_id);

CREATE INDEX ON whse_fish.pscis_events_barrier (model_crossing_id);
CREATE INDEX ON whse_fish.pscis_events_barrier (linear_feature_id);
CREATE INDEX ON whse_fish.pscis_events_barrier (blue_line_key);
CREATE INDEX ON whse_fish.pscis_events_barrier USING GIST (wscode_ltree);
CREATE INDEX ON whse_fish.pscis_events_barrier USING BTREE (wscode_ltree);
CREATE INDEX ON whse_fish.pscis_events_barrier USING GIST (localcode_ltree);
CREATE INDEX ON whse_fish.pscis_events_barrier USING BTREE (localcode_ltree);
CREATE INDEX ON whse_fish.pscis_events_barrier USING GIST (geom);
