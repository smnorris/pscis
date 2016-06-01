-- MISC PSCIS FIXES

-- stream_crossing_id 114 is not on a fish stream, invalid
-- identified because there is no mapped stream nearby, it snaps to exact same spot as nearby bridge
DELETE FROM pscis.pscis_attachments WHERE assessment_id = 114;
DELETE FROM pscis.pscis_structures WHERE structure_id = 114;
DELETE FROM pscis.pscis_stream_cross_loc_point WHERE stream_crossing_id = 114;
DELETE FROM pscis.pscis_crossing_assessments WHERE assessment_id = 114;

-- stream_crossing_id 368 is secondary pipe - invalid
DELETE FROM pscis.pscis_attachments WHERE assessment_id = 368;
DELETE FROM pscis.pscis_structures WHERE structure_id = 368;
DELETE FROM pscis.pscis_stream_cross_loc_point WHERE stream_crossing_id = 368;
DELETE FROM pscis.pscis_crossing_assessments WHERE assessment_id = 368;
