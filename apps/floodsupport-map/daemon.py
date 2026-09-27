"""Keep imports loaded and refresh both sources every five minutes."""

from __future__ import annotations

import logging
from pathlib import Path
import time

import merged_sync


LOG = Path(r"C:\ProgramData\BMAFloodSupport\daemon.log")


def main(interval: int = 300, cycles: int | None = None) -> None:
    logging.basicConfig(filename=LOG, level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s", encoding="utf-8")
    due = time.monotonic()
    count = 0
    while True:
        time.sleep(max(0, due - time.monotonic()))
        started = time.monotonic()
        try:
            result = merged_sync.run()
            logging.info("Sync OK: %s places, %s mapped; API %s, Sheets %s", result["total"], result["mapped"],
                         result["sourceHealth"]["api"], result["sourceHealth"]["sheets"])
        except Exception:
            logging.exception("Sync failed; last public snapshot retained")
        count += 1
        if cycles is not None and count >= cycles:
            return
        due = max(due + interval, started + 1)


if __name__ == "__main__":
    main()
