-- Prune PSCIS duplicates that remain

-- First, find all crossings on same stream within 5m of another
-- in the _prelim3 table

-- Then, by selecting DISTINCT ON blue line key and measure, and sorting,
-- we remove duplicate events, retaining (in order of priority)
--  - higher index status (1 REMEDIATED, 2 DESIGN, 3 ASSESSED)
--  - most recently assessed
--  - closest source point to stream

DROP TABLE IF EXISTS whse_fish.pscis_events;

CREATE TABLE whse_fish.pscis_events AS
SELECT
  stream_crossing_id,
  model_crossing_id,
  distance_to_stream,
  fwa_watershed_code,
  local_watershed_code,
  blue_line_key,
  downstream_route_measure,
  watershed_group_code,
  score
FROM (
  SELECT DISTINCT ON (blue_line_key, m_mid)
      a.stream_crossing_id,
      a.model_crossing_id,
      a.distance_to_stream,
      a.fwa_watershed_code,
      a.local_watershed_code,
      a.blue_line_key,
      a.downstream_route_measure,
      -- find the midpoint between the duplicate crossings so that
      -- we have some way to find unique locations (this doesn't get retained,
      COALESCE(
        (a.downstream_route_measure + b.downstream_route_measure) / 2,
        a.downstream_route_measure)
      AS m_mid,
      ass.assessment_date,
      CASE
        WHEN x.current_pscis_status = 'REMEDIATED' THEN 1
        WHEN x.current_pscis_status = 'DESIGN' THEN 2
        WHEN x.current_pscis_status = 'ASSESSED' THEN 3
      END AS status_idx,
      a.watershed_group_code,
      a.score
  FROM whse_fish.pscis_events_prelim3 a
  LEFT OUTER JOIN
  -- Manually remove a handful of crossings from consideration
  -- (the query fails when there are three sites at one location,
  -- this is an easy fix)
    (SELECT *
       FROM whse_fish.pscis_events_prelim3
      WHERE stream_crossing_id NOT IN (1110, 1106, 6817, 124622, 196740)
    ) b
  -- find points on the same stream, measure is within 5m, not the same pt
    ON a.blue_line_key = b.blue_line_key
   AND abs(a.downstream_route_measure - b.downstream_route_measure) < 5
   AND a.stream_crossing_id != b.stream_crossing_id
  LEFT OUTER JOIN whse_fish.pscis_assessment_svw ass
    ON a.stream_crossing_id = ass.stream_crossing_id
  LEFT OUTER JOIN whse_fish.pscis_points_all x
    ON a.stream_crossing_id = x.stream_crossing_id
  ORDER BY
    blue_line_key,
    m_mid,
    status_idx,
    assessment_date,
    distance_to_stream)
AS prune;

ALTER TABLE whse_fish.pscis_events ADD PRIMARY KEY (stream_crossing_id);