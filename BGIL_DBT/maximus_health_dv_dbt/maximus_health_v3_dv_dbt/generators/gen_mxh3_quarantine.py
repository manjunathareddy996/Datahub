# -*- coding: utf-8 -*-
"""BESPOKE LAYER (declared in the profile): surrogate_child_key_quarantine.

Declared exception per s6.5 -- NOT an unannounced extra generator.

THE BLOCKER. 45 child-key components on 7 RATIFIED Multi-Active SCD2 satellites
are backed by {spine:KEY_HASH} / {spine:PARENT_KEY_HASH} -- a per-row surrogate
minted by the shred layer. It is unique per source row, so EVERY GATE PASSES:
check_collapse sees distinct values, the child key IS resolved, it is
deterministic, on-row and non-renumbering. Resolution and stability are different
properties and no gate here measures the second.

On the next shred rebuild the same business fact is re-hashed, its child key
CHANGES, and the load INSERTS A NEW CHILD ROW instead of closing and versioning
the existing one. The satellite accumulates duplicates and silently stops being a
history.

SCOPED BY FIELD, NEVER BY TEXT: leg_backing == 'surrogate' is exactly 45, and
child_key_tier == 'surrogate' independently is exactly 45. Substring 'KEY_HASH'
gives 2,602 field-values, the literal '{spine:KEY_HASH}' gives 461 -- neither is 45.

NO KEY IS FABRICATED. The conversion population at VIEW grain is 0 of 45: a leg can
only name a column present on its own view. On SAT_POLICY_CERTIFICATE the apparent
business form is a MEMBER-identifier ladder, so converting would merge every
certificate of one member onto one child row.

HOW THE LOSS OF HISTORY IS MADE VISIBLE IN THE EMITTED SQL (not only in a report):
  1. the unstable value is emitted under <LEG>__UNSTABLE_SURROGATE and NOT under
     the model's declared child-key column, so it cannot be wired into a
     satellite by accident;
  2. two literal marker columns state the condition on every row;
  3. the model is emitted DISABLED, so a dbt run cannot load it silently;
  4. the directive and its reason are in the header.
"""
import collections

import mxh3_emit as E
import mxh3_keyrules as K
import mxh3_names as N
from gen_mxh3_stage import key_slots

GEN = "gen_mxh3_quarantine.py"


def main():
    sp = E.spec()
    slots = key_slots(sp)
    byexpr = {}
    for (view, hub, i), d in slots.items():
        byexpr[(view, hub, d["expression"])] = i

    bysat = collections.defaultdict(list)
    comps = 0
    for b in sp["blocks"]:
        surr = [ls for ls in b["leg_status"] if ls["state"] == "surrogate_quarantine"]
        if not surr:
            continue
        comps += len(surr)
        bysat[b["home"]].append((b, surr))

    if comps != 45:
        raise AssertionError(
            "surrogate components are %d, not the published 45. The blocker is scoped BY "
            "FIELD (leg_backing=='surrogate'); if this moved, re-derive before emitting."
            % comps)

    n = 0
    for sat in sorted(bysat):
        rows = bysat[sat]
        declared = sp["model"]["sat_childkey"].get(sat, "")
        parts = []
        for b, surr in sorted(rows, key=lambda x: (x[0]["view"], x[0]["column"])):
            rk = b["resolved_key"]
            hub = rk["hub"] or b["anchor"]
            expr = rk["expression"] or b.get("anchor_expression")
            i = byexpr.get((b["view"], hub, expr)) if (hub and expr) else None
            if i is None:
                continue
            legvals = {lg["leg"]: lg["value"] for lg in b["legs"]}
            cols = []
            for ls in surr:
                leg = ls["leg"]
                raw = legvals.get(leg) or ""
                # The DISPLAY form is not executable. What is emitted is the shred's
                # own row surrogate, under a name that is deliberately NOT the
                # declared child-key column.
                src = ("PARENT_KEY_HASH" if "PARENT_KEY_HASH" in raw else "KEY_HASH")
                if src not in K.view_columns(b["view"]):
                    continue
                cols.append("        %s as %s"
                            % (src, N.fit(N.childkey_column(leg) + "__UNSTABLE_SURROGATE")))
            if not cols:
                continue
            cols = [
                "        md5(upper(%s)) as %s" % (E.bk_name(hub, i), E.hk_name(hub)),
            ] + cols + [
                "        %s as CHILD_KEY_STABILITY_CLASS"
                % K.sql_literal("UNSTABLE_PER_ROW_SHRED_SURROGATE"),
                "        %s as HISTORY_STATUS"
                % K.sql_literal("NOT_LOADED_AS_SCD2_HISTORY"),
                "        %s as DECLARED_CHILD_KEY_NOT_SOURCED"
                % K.sql_literal(declared or "(none declared)"),
                "        %s as QUARANTINE_DIRECTIVE"
                % K.sql_literal("build_directive/directive_kind=surrogate_child_key"),
                "        %s" % E.record_source(b["view"]),
                "        %s" % E.LOAD_DT,
            ]
            parts.append("    select\n" + ",\n".join(cols) +
                         "\n    from {{ ref('%s') }}" % N.stage_name(b["view"]))
        if not parts:
            continue
        sql = "\n".join([
            E.config("view", ["enabled=false", "tags=['quarantine','blocker']"]),
            E.header(GEN, [
                "%s  --  QUARANTINED, NOT A HISTORY" % sat,
                "",
                "declared child key (data_7.js sats[].childkey): %s" % (declared or "(none)"),
                "grain declared by the model                   : %s"
                % sp["model"]["sat_hist"].get(sat),
                "surrogate-backed components on this satellite : %d"
                % sum(len(s) for _b, s in rows),
                "",
                "THIS MODEL IS EMITTED DISABLED. The child key resolves and is unique per",
                "source row, so every gate passes -- but a per-row shred surrogate is NOT",
                "STABLE ACROSS RELOADS. On the next shred rebuild the same business fact",
                "re-hashes, the child key changes, and the load INSERTS A NEW CHILD ROW",
                "instead of versioning the existing one. The satellite would accumulate",
                "duplicates and stop being a history, silently.",
                "",
                "The unstable value is emitted below under <LEG>__UNSTABLE_SURROGATE and",
                "NOT under the declared child-key column, so it cannot be wired into a",
                "satellite by accident. NO KEY IS FABRICATED: the conversion population at",
                "view grain is 0 of 45.",
                "",
                "To clear this: source a STABLE business key for the declared child key,",
                "then route these rows to the ratified satellite. Do not enable this model.",
            ]),
            "",
            "with quarantined as (",
            "\n    union all\n".join(parts),
            ")",
            "",
            "select * from quarantined",
        ])
        E.write_model("quarantine", N.quarantine_name(sat), sql, GEN)
        n += 1

    print("quarantine models emitted    : %d  (BESPOKE, declared in the profile)" % n)
    print("  surrogate components       : %d  (UNIT=components, scoped BY FIELD "
          "leg_backing=='surrogate')" % comps)
    print("  satellites quarantined     : %d of 7 declared" % n)
    print("  these satellites load NO history -- deliberate and visible in the SQL, "
          "not a source gap")
    E.checkpoint("quarantine", n, {"surrogate_components": comps, "satellites": n})
    return n


if __name__ == "__main__":
    main()
