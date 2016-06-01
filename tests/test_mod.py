import pscis


def test_init():
    assert pscis.cfg["dburl"] == "postgresql://postgres:postgres@localhost:5432/postgis"
    assert "assessments" in pscis.queries.keys()


def test_update():
    #pscis.apply_updates()
    table = "pscis.pscis_assessment_svw"
    assert (pscis.db[table]
            .find_one(stream_crossing_id=375)["utm_easting"]) == 513445
