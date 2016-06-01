SELECT
  imer.*,
  sites.imer_pilotareas,
  a.assessment_id,
  a.submission_id,
  a.structure_id,
  x.external_crossing_reference,
  x.stream_name,
  x.road_name,
  x.road_km_mark,
  str.crossing_type_code,
  str.crossing_subtype_code,
  a.assessment_date,
  a.project_id as assmt_project_id,
  p.funding_project_number as assmt_funding_project_number,
  p.funding_source_code as assmt_funding_source_code,
  p.responsible_party_client_name as assmt_resp_party_client_name,
  p.consultant_client_name as assmt_consultant_client_name,
  str.diameter_or_span,
  str.length_or_width,
  a.crew_members,
  a.continuous_embeddedment_ind,
  a.average_depth_embededdment,
  a.resemble_channel_ind,
  a.backwatered_ind,
  a.percentage_backwatered,
  a.fill_depth,
  a.outlet_drop,
  a.outlet_pool_depth,
  a.inlet_drop_ind,
  a.culvert_slope,
  a.downstream_channel_width,
  a.stream_slope,
  a.stream_width_ratio,
  a.beaver_activity_ind,
  a.fish_observed_ind,
  a.valley_fill_code,
  a.habitat_value_code,
  a.embed_score,
  a.culvert_length_score,
  a.outlet_drop_score,
  a.culvert_slope_score,
  a.stream_width_ratio_score,
  a.final_score,
  a.barrier_result_code AS assessment_barrier_result_code,
  CASE
     WHEN rslt.remediation_id IS NOT NULL THEN
      'REMEDIATED'
     WHEN prop.remediation_proposal_id IS NOT NULL THEN
      'DESIGN'
     WHEN a.ASSESSMENT_ID IS NOT NULL THEN
      'ASSESSED'
  END current_pscis_status,
  a.assessment_comment,
  a.crossing_fix_code,
  a.recommended_diameter_or_span,
  'http://a100.gov.bc.ca/pub/pscismap/imageViewer.do?assessmentId='||a.assessment_id as image_view_url,
  'http://a100.gov.bc.ca/pub/acat/public/advancedSearch.do?keywords=[PSCIS'||p.project_id||']&searchKeyType=searchAll&sortColumn=title' as ecocat_url,
  x.geom,
  stream.stream_order
FROM fp_working.imer_summaries_1 imer
INNER JOIN pscis.pscis_stream_cross_loc_point x
ON imer.stream_crossing_id = x.stream_crossing_id
INNER JOIN pscis.pscis_structures str
ON imer.stream_crossing_id = str.stream_crossing_id
AND str.retirement_date is null
INNER JOIN fp_working.imer_points sites
ON imer.stream_crossing_id = sites.stream_crossing_id
LEFT OUTER JOIN pscis.pscis_crossing_assessments a
ON imer.stream_crossing_id = a.stream_crossing_id
LEFT OUTER JOIN pscis.pscis_projects p
ON a.project_id = p.project_id
LEFT OUTER JOIN pscis.pscis_remediation_results rslt
ON imer.stream_crossing_id = rslt.stream_crossing_id
LEFT OUTER JOIN pscis.pscis_remediation_design_props prop
ON imer.stream_crossing_id = prop.stream_crossing_id
INNER JOIN whse_basemapping.fwa_stream_networks_sp stream
ON imer.blue_line_key = stream.blue_line_key
AND stream.downstream_route_measure =
    (SELECT downstream_route_measure
       FROM whse_basemapping.fwa_stream_networks_sp
      WHERE blue_line_key = imer.blue_line_key
        AND downstream_route_measure < imer.downstream_route_measure
   ORDER BY downstream_route_measure DESC
      LIMIT 1);