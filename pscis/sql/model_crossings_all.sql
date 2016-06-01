-- create a table holding all modelled crossings (bridges and culverts),
-- plus add some fwa attribs for matching and networking queries
DROP TABLE IF EXISTS fp_working.model_crossings_all;

CREATE TABLE fp_working.model_crossings_all AS
SELECT
  x.crossing_id,
  'bridge'::text AS model_xing_type,
  x.fwa_watershed_code,
  x.local_watershed_code,
  x.blue_line_key,
  x.downstream_route_measure,
  s.watershed_group_code,
  s.gnis_name,
  s.stream_order,
  x.geom
FROM fish_passage.road_stream_crossings_other x
INNER JOIN whse_basemapping.fwa_stream_networks_sp s
ON x.linear_feature_id = s.linear_feature_id
UNION ALL
SELECT
  x.crossing_id,
  'culvert'::text AS model_xing_type,
  x.fwa_watershed_code,
  x.local_watershed_code,
  x.blue_line_key,
  x.downstream_route_measure,
  s.watershed_group_code,
  s.gnis_name,
  s.stream_order,
  x.geom
FROM fish_passage.road_stream_crossings_culverts x
INNER JOIN whse_basemapping.fwa_stream_networks_sp s
ON x.linear_feature_id = s.linear_feature_id;

-- create indexes
ALTER TABLE fp_working.model_crossings_all ADD PRIMARY KEY (crossing_id);
CREATE INDEX model_x_all_geom ON fp_working.model_crossings_all using gist (geom);