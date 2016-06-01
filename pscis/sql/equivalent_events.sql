-- find events that are in basically the same spot
SELECT
  a.stream_crossing_id,
  x.current_pscis_status stat1,
  b.stream_crossing_id as stream_crossing_id_2,
  y.current_pscis_status stat2,
  abs(a.downstream_route_measure - b.downstream_route_measure) as dist
FROM fp_working.pscis_events a
INNER JOIN fp_working.pscis_events b
-- on the same stream
ON a.blue_line_key = b.blue_line_key
-- downstream_route_measure is < 5m different
AND abs(a.downstream_route_measure - b.downstream_route_measure) < 5
AND a.stream_crossing_id != b.stream_crossing_id
INNER JOIN fp_working.pscis_points_all x ON a.stream_crossing_id = x.stream_crossing_id
INNER JOIN fp_working.pscis_points_all y ON b.stream_crossing_id = y.stream_crossing_id
-- if status is not equivalent, things are all good, those should be in the same spot
Where x.current_pscis_status = y.current_pscis_status
ORDER BY a.blue_line_key, dist