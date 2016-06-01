SELECT
    a.stream_crossing_id as id_1,
    a.distance_to_stream as dist_1,
    ass1.assessment_date as date_1,
    b.stream_crossing_id as id_2,
    b.distance_to_stream as dist_2,
    ass2.assessment_date as date_2,
    abs(a.downstream_route_measure - b.downstream_route_measure) as event_dist,
    st_distance(x.geom, y.geom) as pt_dist
FROM fp_working.pscis_events a
INNER JOIN fp_working.pscis_events b
-- on the same stream
ON a.blue_line_key = b.blue_line_key
-- downstream_route_measure is < 5m different
AND abs(a.downstream_route_measure - b.downstream_route_measure) < %s
AND a.stream_crossing_id != b.stream_crossing_id
INNER JOIN pscis.pscis_points_all x ON a.stream_crossing_id = x.stream_crossing_id
INNER JOIN pscis.pscis_crossing_assessments ass1 ON ass1.stream_crossing_id = x.stream_crossing_id
INNER JOIN pscis.pscis_points_all y ON b.stream_crossing_id = y.stream_crossing_id
INNER JOIN pscis.pscis_crossing_assessments ass2 ON ass2.stream_crossing_id = y.stream_crossing_id
-- if status is not equivalent, things are all good, those should be in the same spot
WHERE x.current_pscis_status = y.current_pscis_status
AND a.stream_crossing_id < b.stream_crossing_id
ORDER BY a.blue_line_key