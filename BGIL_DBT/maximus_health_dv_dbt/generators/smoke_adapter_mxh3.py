"""Smoke run: load the real mxh3 spec through ``adapter_mxh3`` and plan it.

Usage::

    python generators/smoke_adapter_mxh3.py [output_file]

Prints counts (rows, satellites, hubs, links, tables, key slots, walks,
expected prior-unresolved rows), checks that two loads give identical
``health_spec.json`` text, then runs ``dvgen.plan.plan`` and prints timing,
artifact counts by kind and gap counts by track and reason. Output goes to
``output_file`` (default ``%TEMP%/mxh3_smoke.txt``) and to stdout.

If ``dvgen`` is not importable (``sync_dvgen.py`` has not run yet) the OPUS
project's ``generators/`` directory is put on ``sys.path`` read-only.
"""
from __future__ import annotations

import os
import sys
import time
from collections import Counter
from pathlib import Path
from types import SimpleNamespace

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
sys.path.insert(0, str(HERE))
try:
    import dvgen  # noqa: F401
except ImportError:
    sys.path.append(str(ROOT.parent / "opus_health_dv_dbt" / "generators"))

import adapter_mxh3  # noqa: E402
from dvgen import model  # noqa: E402
from dvgen.plan import plan  # noqa: E402


def main(out_path: str | None = None) -> int:
    lines: list[str] = []
    P = lines.append

    t0 = time.perf_counter()
    spec, report = adapter_mxh3.load_mxh3_report(ROOT)
    t_load = time.perf_counter() - t0
    P(f"load: {t_load:.2f}s")
    for key in sorted(report):
        P(f"  {key}: {report[key]}")

    text1 = model.dump_spec(spec)
    text2 = model.dump_spec(adapter_mxh3.load_mxh3(ROOT))
    P(f"deterministic (two loads, identical health_spec text): {text1 == text2}"
      f" ({len(text1):,} chars)")
    back = model.parse_spec(text1)
    P(f"round-trip parse_spec == canonical spec: {back == spec.canonical()}")

    P("satellite tracks: " + str(Counter(s.track for s in spec.satellites)))
    P("satellite parent_origin: " + str(Counter(s.parent_origin for s in spec.satellites)))
    P("key slot origins: " + str(Counter(s.origin for s in spec.key_slots)))
    P("untyped columns: " + str(Counter(c.type_origin for t in spec.tables for c in t.columns)))
    P("key columns: " + str(sum(1 for t in spec.tables for c in t.columns if c.is_key)))
    expected = [r for r in spec.rows if r.spec_unresolved]
    P(f"expected gap rows from spec_unresolved: {len(expected)} "
      + str(Counter(r.spec_unresolved for r in expected)))

    class Cfg:
        PROJECT = adapter_mxh3.PROJECT_NAME
        RECORD_SOURCE_PREFIX = "MAXIMUS_"
        RECORD_SOURCE_GROUP = "MAXIMUS"
        WATERMARK_COLUMN = "inc_job_updated_at"
        WATERMARK_OVERRIDES: dict = {}
        STG1_SOURCE = "maximus_health_raw"
        SPEC_SOURCE = adapter_mxh3.SPEC_REL

    t0 = time.perf_counter()
    result = plan(spec, Cfg)
    t_plan = time.perf_counter() - t0
    P(f"plan: {t_plan:.2f}s")
    P("artifacts: " + str(len(result.artifacts)) + " "
      + str(sorted(Counter(a.kind for a in result.artifacts).items())))
    P("gaps: " + str(len(result.gaps)))
    P("gaps by (track, reason): "
      + str(sorted(Counter((g.track, g.reason) for g in result.gaps).items())))
    P("gap rows (sum of row_ids): " + str(sum(len(g.row_ids) for g in result.gaps)))
    P("gap rows with spec_unresolved covered: "
      + str(len({rid for g in result.gaps for rid in g.row_ids}
                & {r.row_id for r in expected})) + f" of {len(expected)}")
    P("hist_skips: " + str(len(result.hist_skips)) + " not_fed: " + str(len(result.not_fed)))
    P("max artifact path length: " + str(max(len(a.path) for a in result.artifacts)))

    text = "\n".join(lines)
    target = out_path or os.path.join(os.environ.get("TEMP", "."), "mxh3_smoke.txt")
    Path(target).write_text(text + "\n", encoding="utf-8")
    print(text)
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1] if len(sys.argv) > 1 else None))
