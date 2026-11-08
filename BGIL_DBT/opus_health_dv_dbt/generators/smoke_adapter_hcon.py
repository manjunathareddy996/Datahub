"""Smoke run: load the real OPUS inputs, print counts, then run ``plan()``.

Not a test (no ``test_`` prefix, so pytest does not collect it). Usage::

    python generators/smoke_adapter_hcon.py [output.txt]

The report is printed and also written to ``output.txt`` (default
``%TEMP%/smoke_hcon.txt``) because shell output can be lost.
"""
from __future__ import annotations

import io
import os
import sys
import time
from collections import Counter
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

import adapter_hcon  # noqa: E402
import project_config  # noqa: E402
from dvgen.model import dump_spec  # noqa: E402
from dvgen.plan import plan  # noqa: E402


def main(argv: list[str]) -> int:
    out = io.StringIO()

    def p(*a):
        print(*a, file=out)

    root = HERE.parent
    t0 = time.perf_counter()
    loaded = adapter_hcon.load_hcon_full(root)
    t_load = time.perf_counter() - t0
    spec, sibling = loaded.spec, loaded.sibling_model

    p(f"load_hcon: {t_load:.1f}s")
    p("counts:", dict(loaded.counts))
    p("rows by (outcome, target_kind):",
      dict(sorted(Counter((r.outcome, r.target_kind) for r in spec.rows).items())))
    p("rows without vault_code:", sum(1 for r in spec.rows if not r.vault_code))
    p("rows stamped spec_unresolved:",
      dict(Counter(r.spec_unresolved for r in spec.rows if r.spec_unresolved)))
    p("tables:", len(spec.tables),
      "evidence:", dict(Counter(t.has_watermark_evidence for t in spec.tables)))
    p("columns:", sum(len(t.columns) for t in spec.tables),
      "key columns:", sum(1 for t in spec.tables for c in t.columns if c.is_key),
      "type_origin:",
      dict(Counter(c.type_origin for t in spec.tables for c in t.columns)))
    p("slot columns not in views[]:", len(loaded.slot_columns_added))
    p("hubs:", len(spec.hubs), "links:", len(spec.links))
    p("satellites:", len(spec.satellites),
      "by track:", dict(Counter(s.track for s in spec.satellites)),
      "parent none:", sum(1 for s in spec.satellites if s.parent is None),
      "multi-active:", sum(1 for s in spec.satellites if s.is_multi_active))
    p("key slots:", len(spec.key_slots),
      "by origin:", dict(Counter(k.origin for k in spec.key_slots)))
    p("precedence tuples:", len(spec.precedence))
    p("input digests:", len(spec.input_digests))
    p("sibling model:", None if sibling is None else
      f"{len(sibling.sat_parent)} parents from {sibling.source}")
    p("unresolved (kind, records, treatment, records_with_rows, rows_stamped):")
    for item in loaded.unresolved:
        p("  ", item)

    text_a = dump_spec(spec)
    text_b = dump_spec(adapter_hcon.load_hcon(root)[0])
    p("health_spec.json bytes:", len(text_a.encode("utf-8")),
      "deterministic across two loads:", text_a == text_b)

    t1 = time.perf_counter()
    result = plan(spec, project_config, sibling)
    t_plan = time.perf_counter() - t1
    p(f"plan(): {t_plan:.1f}s")
    p("artifacts:", len(result.artifacts),
      dict(sorted(Counter(a.kind for a in result.artifacts).items())))
    p("gaps:", len(result.gaps),
      dict(sorted(Counter(g.reason for g in result.gaps).items())))
    p("gaps by (track, reason):",
      dict(sorted(Counter((g.track, g.reason) for g in result.gaps).items())))
    mp = [g for g in result.gaps if g.reason == "missing_parent"]
    p("missing_parent satellite-level gaps:",
      sum(1 for g in mp if g.source_table == ""),
      "row-level:", sum(1 for g in mp if g.source_table != ""))
    p("watermark risks:", len(result.watermark_risks),
      dict(Counter(w.evidence for w in result.watermark_risks)))
    p("derived facts:", len(result.derived_facts), "hist skips:",
      len(result.hist_skips), "not fed:", len(result.not_fed))

    text = out.getvalue()
    target = Path(argv[1]) if len(argv) > 1 else Path(
        os.environ.get("TEMP", ".")) / "smoke_hcon.txt"
    target.write_text(text, encoding="utf-8")
    print(text)
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
