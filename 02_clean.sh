#!/bin/bash
set -euxo pipefail

psql -f sql/load01_pscis_points_all.sql
psql -f sql/load02_pscis_events_prelim1.sql
psql -f sql/load03_pscis_events_prelim2.sql
psql -f sql/load04_pscis_modelled_crossings_all.sql
psql -f sql/load05_pscis_model_match_pts.sql
psql -f sql/load06_pscis_events_prelim3.sql
psql -f sql/load07_pscis_events.sql
psql -f sql/load08_pscis_points_duplicates.sql
psql -f sql/load09_pscis_model_combined.sql
psql -f sql/load10_cleanup.sql