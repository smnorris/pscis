-- add upstream species codes to pscis/model combined table

ALTER TABLE fish_passage.pscis_model_combined ADD COLUMN species_codes text[];

UPDATE fish_passage.pscis_model_combined a
SET species_codes = spp.species_codes
FROM
(
  SELECT
    pscis_model_combined_id,
    array_agg(species_codes) as species_codes
  FROM
  (
    SELECT DISTINCT
      a.pscis_model_combined_id,
      unnest(o.species_codes) as species_codes
    FROM fish_passage.pscis_model_combined a
    INNER JOIN whse_fish.fiss_fish_obsrvtn_events b
    ON
      (
        a.wscode_ltree = a.localcode_ltree AND
        b.wscode_ltree <@ a.wscode_ltree
      )
        AND
      (
        b.blue_line_key <> a.blue_line_key OR
        b.downstream_route_measure > a.downstream_route_measure + .01
      )
      OR
      (
        a.wscode_ltree != a.localcode_ltree AND
        (
          -- b is child of a
          b.wscode_ltree <@ a.wscode_ltree AND
          (
          -- AND b is the same watershed code, with larger localcode
          -- (query on wscode rather than blkey + measure to capture side channels)
            (b.wscode_ltree = a.wscode_ltree AND b.localcode_ltree > a.localcode_ltree)
             OR
          -- OR b wscode > a localcode and b wscode is not a child of a localcode (tribs)
            (b.wscode_ltree > a.localcode_ltree AND NOT b.wscode_ltree <@ a.localcode_ltree)
             OR
          -- OR blue lines are equivalent and measure is greater
            (b.blue_line_key = a.blue_line_key AND b.downstream_route_measure > a.downstream_route_measure)
          )
        )
      )
    LEFT OUTER JOIN whse_fish.fiss_fish_obsrvtn_distinct o
    ON b.fish_obsrvtn_distinct_id = o.fish_obsrvtn_distinct_id
    ORDER BY pscis_model_combined_id, species_codes
  ) as sp
  GROUP BY pscis_model_combined_id
) as spp
WHERE a.pscis_model_combined_id = spp.pscis_model_combined_id;

-- There are a handful of points not on fish habitat which get given
-- species_codes by above because of bad data. Fix this here.
UPDATE fish_passage.pscis_model_combined
SET species_codes = NULL
WHERE species_codes IS NOT NULL AND fish_habitat = 'NON FISH HABITAT';