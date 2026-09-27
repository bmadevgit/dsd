"""Keep canal water-level data refreshed every five minutes."""

from __future__ import annotations

import logging
from pathlib import Path
import time

import sync_canal_water


LOG = Path(r"C:\ProgramData\BMANowMap\canal-water-daemon.log")


def main(interval: int = 300, cycles: int | None = None) -> None:
    LOG.parent.mkdir(parents=True, exist_ok=True)
    logging.basicConfig(filename=LOG, level=logging.INFO,
                        format="%(asctime)s %(levelname)s %(message)s", encoding="utf-8")
    due = time.monotonic()
    count = 0
    while True:
        time.sleep(max(0, due - time.monotonic()))
        sync_canal_water.sync()
        count += 1
        if cycles is not None and count >= cycles:
            return
        due = max(due + interval, time.monotonic() + 1)


if __name__ == "__main__":
    main()
