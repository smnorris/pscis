DROP TABLE IF EXISTS whse_fish.pscis_points_all;

CREATE TABLE whse_fish.pscis_points_all AS
SELECT
 stream_crossing_id::integer,
 current_pscis_status,
 current_barrier_result_code,
 current_crossing_type_code,
 current_crossing_subtype_code,
 geom
FROM whse_fish.pscis_assessment_svw
WHERE current_pscis_status = 'ASSESSED'
UNION ALL
SELECT
 stream_crossing_id::integer,
 current_pscis_status,
 current_barrier_result_code,
 current_crossing_type_code,
 current_crossing_subtype_code,
 geom
FROM whse_fish.pscis_habitat_confirmation_svw
WHERE current_pscis_status = 'CONFIRMATION'
UNION ALL
SELECT
 stream_crossing_id::integer,
 current_pscis_status,
 current_barrier_result_code,
 current_crossing_type_code,
 current_crossing_subtype_code,
 geom
FROM whse_fish.pscis_design_proposal_svw
WHERE current_pscis_status = 'DESIGN'
UNION ALL
SELECT
 stream_crossing_id::integer,
 current_pscis_status,
 current_barrier_result_code,
 current_crossing_type_code,
 current_crossing_subtype_code,
 geom
FROM whse_fish.pscis_remediation_svw
WHERE current_pscis_status = 'REMEDIATED';

ALTER TABLE whse_fish.pscis_points_all ADD PRIMARY KEY (stream_crossing_id);
CREATE INDEX ON whse_fish.pscis_points_all USING GIST (geom);