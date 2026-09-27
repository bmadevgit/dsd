"""Small scheduled-task bootstrap with a traceback if Python stalls."""

import faulthandler
from datetime import datetime
import importlib
from pathlib import Path
import runpy


log = Path(r"C:\ProgramData\BMAFloodSupport\bootstrap.log")
with log.open("a", encoding="utf-8", buffering=1) as stream:
    stream.write(f"{datetime.now().isoformat()} BOOT\n")
    faulthandler.dump_traceback_later(25, repeat=True, file=stream)
    try:
        importlib.import_module("merged_sync")
        faulthandler.cancel_dump_traceback_later()
        runpy.run_path(r"C:\inetpub\apps\floodsupport-map\daemon.py", run_name="__main__")
    finally:
        faulthandler.cancel_dump_traceback_later()
        stream.write(f"{datetime.now().isoformat()} EXIT\n")
