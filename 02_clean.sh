psql -f sql/pscis_load01_all_points.sql
psql -f sql/pscis_load02_events_prelim1.sql
psql -f sql/pscis_load03_events_prelim2.sql
psql -f sql/pscis_load04_modelled_crossings_all.sql
psql -f sql/pscis_load05_model_match_pts.sql
psql -f sql/pscis_load06_events_prelim3.sql
psql -f sql/pscis_load07_events_prune.sql
psql -f sql/pscis_load08_events_barrier.sql
psql -f sql/pscis_load09_duplicates.sql
psql -f sql/pscis_load10_cleanup.sql