#!/bin/bash
set -euxo pipefail

bcdata bc2pg WHSE_FISH.PSCIS_ASSESSMENT_SVW
bcdata bc2pg WHSE_FISH.PSCIS_DESIGN_PROPOSAL_SVW
bcdata bc2pg WHSE_FISH.PSCIS_HABITAT_CONFIRMATION_SVW
bcdata bc2pg WHSE_FISH.PSCIS_REMEDIATION_SVW

# load the CWF generated PSCIS - stream - modelled crossing lookup table
# this matches all PSCIS crossings (as of July 2020) to streams/modelled crossings where possible
# null values indicate that the PSCIS crossing does not match to a FWA stream
psql -c "DROP TABLE IF EXISTS whse_fish.pscis_stream_matching"
psql -c "CREATE TABLE whse_fish.pscis_stream_matching (stream_crossing_id integer primary key, model_crossing_id integer, linear_feature_id integer)"
psql -c "\copy whse_fish.pscis_stream_matching FROM 'data/pscis_stream_matching.csv' delimiter ',' csv header"
