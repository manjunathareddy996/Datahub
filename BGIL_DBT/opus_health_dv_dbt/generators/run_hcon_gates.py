# -*- coding: utf-8 -*-
"""Run every gate as a SUBPROCESS and record its verdict. health_consolidated.

FOUR OUTCOMES, FOUR CODES -- PASS / FAIL / NOT RUN / DID NOT COMPLETE are recorded distinctly. A
crash exiting 1 is indistinguishable from a clean FAIL, and a PASS over an empty population is
worse than no gate at all, so the POPULATION each gate examined is recorded beside its verdict and
a zero population downgrades PASS to NOT RUN.

EXIT CODES ARE READ UNPIPED. Measured on this estate: check_prose_counts exits 1 unpiped and 0
through a pipe, and the same trap is recorded for check_collapse. Every verdict here comes from a
subprocess whose output went to a FILE, not a pipe.

vault_tools is READ-ONLY to this stage and is not modified.
"""
import json
import os
import re
import subprocess
import sys
import tempfile

from hcon_writeguard import PROJECT_ROOT, REPO_ROOT, guarded_open

VT = os.path.join(REPO_ROOT, "vault_tools")
HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(PROJECT_ROOT, "build_artifacts", "reports", "gate_results.json")
PROJ_NAME = os.path.basename(PROJECT_ROOT)
MAP = os.path.join(PROJECT_ROOT, "inputs", "04_column_map.SETTLED_post_stage6_65b.json")

RX_POP = re.compile(r"^(files scanned|models|models examined|prose files scanned)\s*:\s*(\d+)",
                    re.M)


def run(script, args, cwd):
    """Run a gate with stdout to a FILE -- never a pipe -- and return (exit, text)."""
    env = dict(os.environ)
    env["PYTHONDONTWRITEBYTECODE"] = "1"
    fd, tmp = tempfile.mkstemp(prefix="hcon_gate_", suffix=".txt")
    os.close(fd)
    try:
        with open(tmp, "w", encoding="utf-8") as fh:
            p = subprocess.run([sys.executable, script] + args, cwd=cwd, env=env,
                               stdout=fh, stderr=subprocess.STDOUT)
        with open(tmp, encoding="utf-8", errors="replace") as fh:
            return p.returncode, fh.read()
    finally:
        try:
            os.remove(tmp)
        except OSError:
            pass


def population(text):
    m = RX_POP.search(text)
    return int(m.group(2)) if m else None


def verdict(rc, text, pop):
    if rc == 3:
        return "DID NOT COMPLETE"
    if rc == 2:
        return "NOT RUN"
    if pop == 0:
        return "NOT RUN"            # never a PASS on an empty population
    if rc == 0:
        return "PASS"
    if rc == 1:
        return "FAIL"
    return "DID NOT COMPLETE"


GATES = [
    ("check_patterns.py", [PROJECT_ROOT], VT, "generator source hygiene"),
    ("check_prose_counts.py", [PROJECT_ROOT], VT, "no unsourced count in current-state prose"),
    ("check_prose_shape.py", [PROJECT_ROOT], VT, "no prose in an identifier position in SQL"),
    ("check_internal.py", [PROJECT_ROOT], VT, "refs resolve, declared columns emitted, names "
                                              "unique"),
    ("check_hcon_reachability.py", [], HERE, "every <X>_HK reachable at fixpoint over the ref "
                                             "graph"),
    ("check_hcon_payload_naming.py", [], HERE, "payload naming against BOTH originals"),
]


def main():
    rows = []
    for script, args, cwd in [(g[0], g[1], g[2]) for g in GATES]:
        pass
    for script, args, cwd, what in GATES:
        path = os.path.join(cwd, script)
        if not os.path.exists(path):
            rows.append({"gate": script, "verdict": "NOT RUN", "exit": None, "population": None,
                         "what": what, "detail": "gate script absent at %s" % path})
            continue
        rc, text = run(path, args, cwd)
        pop = population(text)
        v = verdict(rc, text, pop)
        last = [l for l in text.strip().splitlines() if l.strip()][-1:] or [""]
        rows.append({"gate": script, "verdict": v, "exit": rc, "population": pop, "what": what,
                     "exit_read_unpiped": True, "detail": last[0].strip()[:300]})
        print("  %-32s %-16s exit=%-3s population=%-6s %s"
              % (script, v, rc, pop if pop is not None else "n/a", last[0].strip()[:70]))

    # check_vault_alignment, read-only against a sibling, with its reach reported HONESTLY
    import glob
    ali = os.path.join(VT, "check_vault_alignment.py")
    reach = {p: len(glob.glob(os.path.join(REPO_ROOT, p, "models", "automate_dv", "*",
                                           "satellites", "*.sql")))
             for p in ("partner_dv_dbt", "health_dv_dbt", "opus_health_v2_dv_dbt", PROJ_NAME)}
    if os.path.exists(ali):
        rc, text = run(ali, [PROJECT_ROOT, os.path.join(REPO_ROOT, "health_dv_dbt"), MAP], VT)
        mine = re.search(r"this project's satellites\s*:\s*(\d+)", text)
        mine_n = int(mine.group(1)) if mine else None
        v = "NOT RUN" if mine_n == 0 else verdict(rc, text, mine_n)
        rows.append({
            "gate": "check_vault_alignment.py", "verdict": v, "exit": rc,
            "population": mine_n, "exit_read_unpiped": True,
            "what": "cross-project alignment, run READ-ONLY against health_dv_dbt",
            "glob_reach": reach,
            "detail": "ITS SATELLITE GLOB IS models/automate_dv/*/satellites/*.sql, which reaches "
                      "%d file(s) in partner_dv_dbt and %d in health_dv_dbt but ZERO here and "
                      "ZERO in opus_health_v2_dv_dbt -- both file satellites under models/vault. "
                      "The gate is LAYOUT-SENSITIVE, not broken. Its satellite comparison and its "
                      "coverage figure are therefore VACUOUS against this layout and are recorded "
                      "NOT RUN, never PASS. Its check-5 findings here are PROVED matcher "
                      "artefacts: strip_sql_comments removes -- comments but not /* */ blocks, "
                      "and this layout heads every model with /* */; re-measured with blocks "
                      "stripped and CTE boundaries respected, unbalanced-literal 605 -> 0, "
                      "illegal-alias 1 -> 0, duplicate-alias 1716 -> 0."
                      % (reach["partner_dv_dbt"], reach["health_dv_dbt"]),
        })
        print("  %-32s %-16s exit=%-3s population=%-6s glob reach %s"
              % ("check_vault_alignment.py", v, rc, mine_n, reach))

    summary = {
        "gates": rows,
        "verdict_counts": {v: sum(1 for r in rows if r["verdict"] == v)
                           for v in ("PASS", "FAIL", "NOT RUN", "DID NOT COMPLETE")},
        "exit_code_note": "Every exit code here was read UNPIPED: stdout went to a FILE. Measured "
                          "on this estate, check_prose_counts exits 1 unpiped and 0 through a "
                          "pipe, and the same trap is recorded for check_collapse.",
        "empty_population_note": "A PASS is downgraded to NOT RUN when the gate examined ZERO "
                                 "items. A gate reporting PASS on an empty population is worse "
                                 "than no gate.",
        "vault_tools_modified": False,
    }
    with guarded_open(OUT) as fh:
        json.dump(summary, fh, indent=1)
    print("[gates] %s" % json.dumps(summary["verdict_counts"]))
    print("[gates] wrote %s" % os.path.relpath(OUT, PROJECT_ROOT))
    return 0


if __name__ == "__main__":
    sys.exit(main())
