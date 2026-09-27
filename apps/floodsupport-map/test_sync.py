import unittest
from unittest.mock import Mock, patch

import sync


class CoordinateSafetyTests(unittest.TestCase):
    def test_accepts_only_explicit_place_target(self):
        url = "https://www.google.com/maps/place/School/@13.7,100.5,17z/data=!8m2!3d13.71!4d100.51"
        self.assertEqual(sync.google_target(url)["lat"], 13.71)
        self.assertEqual(sync.google_target(url)["lon"], 100.51)
        self.assertIsNone(sync.google_target("https://www.google.com/maps/place/School/@13.7,100.5,17z"))
        self.assertIsNone(sync.google_target("https://maps.app.goo.gl/example"))
        self.assertIsNone(sync.google_target("https://www.google.com/maps/dir//School/data=!8m2!3d13.71!4d100.51"))

    def test_rejects_ambiguous_and_outside_points(self):
        self.assertIsNone(sync.google_target("https://www.google.com/maps/place/A/data=!3d13.7!4d100.5!3d13.8!4d100.6"))
        self.assertIsNone(sync.google_target("https://www.google.com/maps/place/A/data=!3d15.1!4d100.5"))

    @patch("sync.requests.get")
    def test_poi_requires_one_exact_name_and_district(self, get):
        feature = {"attributes": {"OBJECTID": 7, "NAME": "โรงเรียน ก", "DISTRICT": "เขต ก"}, "geometry": {"x": 100.55, "y": 13.75}}
        response = Mock()
        response.json.return_value = {"features": [feature]}
        get.return_value = response
        self.assertEqual(sync.query_poi("โรงเรียน ก", "เขต ก")["poiObjectId"], 7)
        response.json.return_value = {"features": [feature, feature]}
        self.assertIsNone(sync.query_poi("โรงเรียน ก", "เขต ก"))
        response.json.return_value = {"features": [{**feature, "attributes": {**feature["attributes"], "DISTRICT": "เขต ข"}}]}
        self.assertIsNone(sync.query_poi("โรงเรียน ก", "เขต ก"))

    @patch("sync.fetch_source", side_effect=RuntimeError("source unavailable"))
    def test_source_failure_does_not_replace_snapshot(self, _get):
        before = sync.OUTPUT.read_bytes()
        with self.assertRaises(RuntimeError):
            sync.run()
        self.assertEqual(sync.OUTPUT.read_bytes(), before)


if __name__ == "__main__":
    unittest.main()
