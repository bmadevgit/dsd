import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import sync_canal_water


class CanalWaterSyncTests(unittest.TestCase):
    def station_info(self):
        return [
            {'code': f'WL.TEST.{index:03}', 'name': f'สถานี {index}',
             'river': 'คลองทดสอบ', 'district': 'เขตทดสอบ',
             'latitude': '13.7', 'longitude': '100.5'}
            for index in range(200)
        ]

    def payload(self):
        return [
            {'code': f'WL.TEST.{index:03}', 'site_time': '2026-09-27T18:45:00',
             'status': 'ปกติ', 'wl_in': '0.25', 'wl_out01': '', 'wl_out02': ''}
            for index in range(200)
        ]

    def test_validates_and_reduces_canal_response(self):
        rows, total = sync_canal_water.validate(self.payload(), self.station_info())
        self.assertEqual(total, 200)
        self.assertEqual(len(rows), 200)
        self.assertEqual(rows[0]['levelM'], 0.25)
        self.assertEqual(rows[0]['observedAt'], '2026-09-27T18:45:00+07:00')
        self.assertEqual(rows[0]['river'], 'คลองทดสอบ')
        self.assertEqual(rows[0]['name'], 'สถานี 0')
        self.assertNotIn('pumpdata', rows[0])

    def test_failed_fetch_keeps_last_snapshot(self):
        with tempfile.TemporaryDirectory() as folder:
            output = Path(folder) / 'canal.json'
            key_path = Path(folder) / 'key.txt'
            key_path.write_text('test-key', encoding='utf-8')
            original = {'lastFetchedAt': '2026-09-27T10:00:00Z', 'stations': [{'code': '1'}]}
            output.write_text(json.dumps(original), encoding='utf-8')
            with patch.object(sync_canal_water, 'urlopen', side_effect=TimeoutError('offline')):
                self.assertFalse(sync_canal_water.sync(output, key_path))
            saved = json.loads(output.read_text(encoding='utf-8'))
            self.assertEqual(saved['stations'], original['stations'])
            self.assertEqual(saved['lastFetchedAt'], original['lastFetchedAt'])
            self.assertTrue(saved['fetchFailed'])


if __name__ == '__main__':
    unittest.main()
