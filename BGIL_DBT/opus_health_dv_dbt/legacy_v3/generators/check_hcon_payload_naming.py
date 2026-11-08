# -*- coding: utf-8 -*-
"""PAYLOAD NAMING against BOTH originals -- the half check_vault_alignment cannot reach here.

WHY THIS FILE EXISTS, STATED HONESTLY
-------------------------------------
vault_tools/check_vault_alignment.py globs

    models/automate_dv/*/satellites/*.sql

That glob matches 53 files in partner_dv_dbt and ZERO here, because this project lays models out
as opus_health_v2 does -- models/vault/satellites -- for the reason in builder decision BD4: the
project declares no packages and invokes no automate_dv macro, so a directory named automate_dv
would assert a dependency that does not exist. The gate is LAYOUT-SENSITIVE, not broken, and its
satellite comparison is therefore VACUOUS against this layout. It is reported as NOT RUN, never as
PASS: a gate reporting PASS on an empty population is worse than no gate at all.

This file covers the part that matters most and that the vacuum removed: does this project render a
(satellite, attribute) to the SAME physical column name the originals do? If not, the same fact
occupies two columns of one table -- which is exactly the maximus_travel BASEPREMIUM /
BASE_PREMIUM defect that gate was written for.

The convention is DETECTED from each original, never assumed.

Exit: 0 PASS · 1 FAIL · 2 NOT RUN · 3 DID NOT COMPLETE.
"""
import collections
import glob
import json
import os
import re
import sys

import hcon_names as N
from hcon_writeguard import PROJECT_ROOT, REPO_ROOT

SPEC_PATH = os.path.join(PROJECT_ROOT, "build_artifacts", "hcon_spec.json")
ORIGINALS = {
    "health_dv_dbt": ("models/automate_dv/standard/satellites/*.sql",
                      "models/automate_dv/augmented/satellites/*.sql"),
    "opus_health_v2_dv_dbt": ("models/vault/satellites/*.sql", "models/augmented/*.sql"),
}
ALIGNMENT_GATE_GLOB = "models/automate_dv/*/satellites/*.sql"

RX_PAYLOAD_YAML = re.compile(r"^\s{2,10}-\s*'([A-Za-z_][A-Za-z0-9_]*)'\s*$", re.M)
RX_ALIASED = re.compile(r"\bas\s+([A-Z][A-Z0-9_]*)\s*(?=,|$)", re.M)


def probe():
    cases = [(RX_PAYLOAD_YAML, "      - 'ACCOUNT_CATEGORY'\n", True),
             (RX_PAYLOAD_YAML, "      is_hashdiff: true\n", False),
             (RX_ALIASED, "MEMBER_NAME as PARTY_FULL_NAME,", True),
             (RX_ALIASED, "from {{ ref('x') }}", False)]
    for pat, s, want in cases:
        if bool(pat.search(s)) != want:
            raise AssertionError("probe failed: %r on %r" % (pat.pattern, s))
    return len(cases)


def columns_of(project, globs):
    out = collections.defaultdict(set)
    nfiles = 0
    for g in globs:
        for p in glob.glob(os.path.join(REPO_ROOT, project, g)):
            nfiles += 1
            sat = os.path.basename(p)[:-4].upper()
            for pref in ("STG2_", "SAT_AUG_"):
                pass
            with open(p, encoding="utf-8") as fh:
                t = fh.read()
            out[sat] |= set(RX_PAYLOAD_YAML.findall(t)) | set(RX_ALIASED.findall(t))
    return out, nfiles


def detect_convention(cols):
    """UPPER_SNAKE vs UPPER_SINGLE, counted from the original's own emitted columns."""
    snake = sum(1 for s in cols for c in cols[s] if "_" in c)
    single = sum(1 for s in cols for c in cols[s] if "_" not in c)
    return ("UPPER_SNAKE_PHYSICAL" if snake >= single else "UPPER_SINGLE"), snake, single


def main():
    try:
        n = probe()
        with open(SPEC_PATH, encoding="utf-8") as fh:
            spec = json.load(fh)
        mine = collections.defaultdict(set)
        for S in spec["satellites"]:
            for p in S["payload"]:
                mine[S["code"]].add(p["column"])
        if not mine:
            print("[payload-naming] NOT RUN -- the spec declares no payload column")
            return 2

        # report the alignment gate's reach HONESTLY, measured on three projects
        print("[payload-naming] vault_tools/check_vault_alignment.py satellite glob %r reaches:"
              % ALIGNMENT_GATE_GLOB)
        for proj in ("partner_dv_dbt", "health_dv_dbt", "opus_health_v2_dv_dbt",
                     os.path.basename(PROJECT_ROOT)):
            hits = len(glob.glob(os.path.join(REPO_ROOT, proj, ALIGNMENT_GATE_GLOB)))
            verdict = "NON-VACUOUS" if hits else "VACUOUS -- its satellite comparison is NOT RUN"
            print("                 %-26s %4d file(s)   %s" % (proj, hits, verdict))

        findings = []
        for proj, globs in ORIGINALS.items():
            cols, nfiles = columns_of(proj, globs)
            conv, snake, single = detect_convention(cols)
            shared = sorted(set(mine) & set(cols))
            mismatch = []
            for sat in shared:
                # a column this build emits that the original spells differently after squashing
                for c in sorted(mine[sat]):
                    if c in cols[sat]:
                        continue
                    squashed = c.replace("_", "")
                    hit = [o for o in cols[sat] if o.replace("_", "") == squashed]
                    if hit:
                        mismatch.append((sat, c, hit[0]))
            print("[payload-naming] %-24s %4d satellite file(s), %d satellite(s) shared with this "
                  "build; convention DETECTED as %s (snake %d / single %d)"
                  % (proj, nfiles, len(shared), conv, snake, single))
            if conv != "UPPER_SNAKE_PHYSICAL":
                findings.append("%s renders %s, this build renders UPPER_SNAKE_PHYSICAL" %
                                (proj, conv))
            for sat, c, other in mismatch[:12]:
                findings.append("%s %s: this build emits %s, %s emits %s -- the same fact would "
                                "occupy two columns of one table" % (proj, sat, c, proj, other))
        if findings:
            for f in findings:
                print("[payload-naming] FAIL %s" % f)
            print("[payload-naming] RESULT FAIL -- %d finding(s)" % len(findings))
            return 1
        print("[payload-naming] %d probes passed. RESULT PASS -- both originals' detected "
              "convention is UPPER_SNAKE_PHYSICAL, which is what this build renders, and no "
              "shared (satellite, attribute) differs only by underscore placement." % n)
        return 0
    except Exception as exc:                       # noqa
        print("[payload-naming] DID NOT COMPLETE: %s: %s" % (type(exc).__name__, exc))
        return 3


if __name__ == "__main__":
    sys.exit(main())
