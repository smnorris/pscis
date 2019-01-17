-- MISC PSCIS FIXES

-- stream_crossing_id 114 is not on a fish stream, invalid
-- identified because there is no mapped stream nearby, it snaps to exact same spot as nearby bridge
DELETE FROM pscis.pscis_attachments WHERE assessment_id = 114;
DELETE FROM pscis.pscis_crossing_assessments WHERE assessment_id = 114;
DELETE FROM pscis.pscis_structures WHERE structure_id = 114;
DELETE FROM pscis.pscis_stream_cross_loc_point WHERE stream_crossing_id = 114;

-- stream_crossing_id 368 is secondary pipe - invalid
DELETE FROM pscis.pscis_attachments WHERE assessment_id = 368;
DELETE FROM pscis.pscis_crossing_assessments WHERE assessment_id = 368;
DELETE FROM pscis.pscis_structures WHERE structure_id = 368;
DELETE FROM pscis.pscis_stream_cross_loc_point WHERE stream_crossing_id = 368;

-- fix request from Craig
-- Could you please include a line in your script which deletes one of
-- the re-assessment records for each of the following PSCIS Crossing IDs:
-- (196000,196001,196002,196003)
-- delete in order: attachments, assessments, structures
DELETE FROM pscis.pscis_attachments
WHERE assessment_id in (196400, 196403, 196404, 196405);
DELETE FROM pscis.pscis_crossing_assessments
WHERE assessment_id in (196400, 196403, 196404, 196405);
DELETE FROM pscis.pscis_structures
WHERE structure_id IN  (196380, 196383, 196384, 196385);
--WHERE assessment_id in (196400, 196403, 196404, 196405);