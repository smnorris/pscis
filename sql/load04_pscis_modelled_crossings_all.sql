-- create a table holding all modelled crossings (bridges and culverts),
-- plus add some fwa attribs for matching and networking queries

DROP TABLE IF EXISTS fish_passage.modelled_crossings_all;

CREATE TABLE fish_passage.modelled_crossings_all AS
SELECT
  x.crossing_id,
  'bridge'::text AS model_xing_type,
  x.linear_feature_id,
  x.wscode_ltree,
  x.localcode_ltree,
  x.fwa_watershed_code,
  x.local_watershed_code,
  x.blue_line_key,
  x.downstream_route_measure,
  s.watershed_group_code,
  s.gnis_name,
  s.stream_order,
  x.geom
FROM fish_passage.modelled_crossings_closed_bottom x
INNER JOIN whse_basemapping.fwa_stream_networks_sp s
ON x.linear_feature_id = s.linear_feature_id
UNION ALL
SELECT
  x.crossing_id,
  'culvert'::text AS model_xing_type,
  x.linear_feature_id,
  x.wscode_ltree,
  x.localcode_ltree,
  x.fwa_watershed_code,
  x.local_watershed_code,
  x.blue_line_key,
  x.downstream_route_measure,
  s.watershed_group_code,
  s.gnis_name,
  s.stream_order,
  x.geom
FROM fish_passage.modelled_crossings_open_bottom x
INNER JOIN whse_basemapping.fwa_stream_networks_sp s
ON x.linear_feature_id = s.linear_feature_id;

-- create indexes
ALTER TABLE fish_passage.modelled_crossings_all ADD PRIMARY KEY (crossing_id);
CREATE INDEX ON fish_passage.modelled_crossings_all using gist (geom);