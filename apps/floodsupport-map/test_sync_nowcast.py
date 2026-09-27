import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import sync_nowcast


class NowcastSyncTests(unittest.TestCase):
    def test_failed_fetch_preserves_last_valid_payload(self):
        with tempfile.TemporaryDirectory() as folder:
            output = Path(folder) / 'nowcast.json'
            original = {'lastFetchedAt': '2026-09-27T00:00:00Z', 'payload': {'run_id': 'valid', 'districts': {}}}
            output.write_text(json.dumps(original), encoding='utf-8')
            with patch.object(sync_nowcast, 'urlopen', side_effect=TimeoutError('offline')):
                self.assertFalse(sync_nowcast.sync(output=output))
            saved = json.loads(output.read_text(encoding='utf-8'))
            self.assertEqual(saved['payload'], original['payload'])
            self.assertEqual(saved['lastFetchedAt'], original['lastFetchedAt'])
            self.assertTrue(saved['fetchFailed'])
            self.assertIn('lastAttemptAt', saved)

    def test_rejects_partial_payload(self):
        with self.assertRaises(ValueError):
            sync_nowcast.validate({'run_id': 'bad', 'generated_at': 'today', 'districts': {'1001': {}}})


if __name__ == '__main__':
    unittest.main()
