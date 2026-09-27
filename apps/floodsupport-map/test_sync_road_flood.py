import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import sync_road_flood


class RoadFloodSyncTests(unittest.TestCase):
    def test_failed_fetch_keeps_last_snapshot_and_marks_failure(self):
        with tempfile.TemporaryDirectory() as folder:
            output = Path(folder) / 'road.json'
            key_path = Path(folder) / 'key.txt'
            key_path.write_text('test-key', encoding='utf-8')
            original = {'lastFetchedAt': '2026-09-27T10:00:00Z', 'sensors': [{'id': '1'}], 'total': 1}
            output.write_text(json.dumps(original), encoding='utf-8')
            with patch.object(sync_road_flood, 'urlopen', side_effect=TimeoutError('offline')):
                self.assertFalse(sync_road_flood.sync(output=output, key_path=key_path))
            saved = json.loads(output.read_text(encoding='utf-8'))
            self.assertEqual(saved['sensors'], original['sensors'])
            self.assertEqual(saved['lastFetchedAt'], original['lastFetchedAt'])
            self.assertTrue(saved['fetchFailed'])

    def test_rejects_partial_source_response(self):
        with self.assertRaises(ValueError):
            sync_road_flood.validate({'data': [{'sensor_profile_id': 1}], 'meta': {'total': 2}})


if __name__ == '__main__':
    unittest.main()
