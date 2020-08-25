-- create pscis events table, linking pscis points to streams
DROP TABLE IF EXISTS whse_fish.pscis_events;

CREATE TABLE whse_fish.pscis_events
(
 stream_crossing_id       integer  PRIMARY KEY ,
 model_crossing_id        integer              ,
 distance_to_stream       double precision     ,
 linear_feature_id        bigint               ,
 wscode_ltree             ltree                ,
 localcode_ltree          ltree                ,
 fwa_watershed_code       text                 ,
 local_watershed_code     text                 ,
 blue_line_key            integer              ,
 downstream_route_measure double precision     ,
 watershed_group_code     character varying(4) ,
 score                    integer
);

-- first, insert PSCIS points that have been manually matched to streams (by CWF)
-- note that we include features that we know are not matched to streams,
-- this ensures they are not added in later steps. Delete them later.
INSERT INTO whse_fish.pscis_events
SELECT
  a.stream_crossing_id,
  a.model_crossing_id,
  ST_Distance(p.geom, s.geom) as distance_to_stream,
  a.linear_feature_id,
  s.wscode_ltree,
  s.localcode_ltree,
  s.fwa_watershed_code,
  s.local_watershed_code,
  s.blue_line_key,
  (ST_LineLocatePoint(
    s.geom, ST_ClosestPoint(s.geom,
                            p.geom)
    )
     * s.length_metre) + s.downstream_route_measure
    AS downstream_route_measure,
  s.watershed_group_code,
  NULL as score
FROM whse_fish.pscis_stream_matching a
INNER JOIN whse_fish.pscis_points_all p
ON a.stream_crossing_id = p.stream_crossing_id
LEFT OUTER JOIN whse_basemapping.fwa_stream_networks_sp s
ON a.linear_feature_id = s.linear_feature_id;

-- Now insert data from the prelim tables, pruning PSCIS duplicates that remain

-- First, find all crossings on same stream within 5m of another
-- in the _prelim3 table

-- Then, by selecting DISTINCT ON blue line key and measure, and sorting,
-- we remove duplicate events, retaining (in order of priority)
--  - higher index status (1 REMEDIATED, 2 DESIGN, 3 ASSESSED)
--  - most recently assessed
--  - closest source point to stream


INSERT INTO whse_fish.pscis_events
SELECT
  stream_crossing_id,
  model_crossing_id,
  distance_to_stream,
  linear_feature_id,
  wscode_ltree,
  localcode_ltree,
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
      a.linear_feature_id,
      a.wscode_ltree,
      a.localcode_ltree,
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
AS prune
ON CONFLICT DO NOTHING; -- don't re-insert data we've already manually matched

-- now delete crossings that aren't matched to streams
DELETE FROM whse_fish.pscis_events WHERE linear_feature_id IS NULL;
