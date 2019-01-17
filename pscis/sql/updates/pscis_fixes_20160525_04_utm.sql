-- MATCH UTM COORDINATES TO GEOMETRIES CHANGED IN PREVIOUS FIXES

-- Strandby River trib, Madrone
UPDATE pscis.pscis_stream_cross_loc_point
SET who_updated = 'DATAFIX_20160525',

  utm_zone = 9,
  utm_easting = 572844,
  utm_northing = 5617117
WHERE stream_crossing_id = 102299;

-- McNair Creek (missing a zero)
UPDATE pscis.pscis_stream_cross_loc_point
SET who_updated = 'DATAFIX_20160525',

  utm_easting = 463970
WHERE stream_crossing_id = 69197;