# -*- coding: utf-8 -*-
"""BESPOKE LAYER (declared in the profile): reference_decode_gate.

Declared exception per s6.5 -- NOT an unannounced extra generator.

3 rows assert code->decode into a human-readable LABEL target. Loading the raw
code where a label belongs is WRONG DATA, not absent data, and every gate passes
it: the column is populated, typed and non-null. No standard layer conditions a
column on the availability of an external decode, so this is a declared bespoke
predicate: REFUSE THE ROW when the decode is unavailable.

SCOPE. These 3 are selected by directive_kind == 'reference_decode', the typed
field the round-2 map added. In the round-1 map the only discriminator was prose
in build_note, and transformation_kind == 'reference_decode' is 59 BLOCKS -- so a
gate scoped by transformation_kind alone over-applies to 56 rows that carry no
directive. The directive population is defined by the DIRECTIVE field.

DEFAULT = REFUSE (builder decision D1). No reference-decode master exists anywhere
in this bundle. One line to overrule: set the dbt var below to true.
"""
import collections

import mxh3_emit as E
import mxh3_keyrules as K
import mxh3_names as N
from gen_mxh3_stage import key_slots

GEN = "gen_mxh3_refdecode.py"
VAR = "mxh3_reference_decode_available"


def main():
    sp = E.spec()
    slots = key_slots(sp)
    byexpr = {}
    for (view, hub, i), d in slots.items():
        byexpr[(view, hub, d["expression"])] = i

    rows = [b for b in sp["blocks"] if b["directive_kind"] == "reference_decode"]
    if len(rows) != 3:
        raise AssertionError(
            "directive_kind=='reference_decode' selects %d blocks, expected 3. The scope is "
            "the DIRECTIVE field; transformation_kind=='reference_decode' is 59 and would "
            "over-apply by 56." % len(rows))

    bysat = collections.defaultdict(list)
    for b in rows:
        bysat[b["home"]].append(b)

    n = 0
    for sat in sorted(bysat):
        bs = bysat[sat]
        parts = []
        for b in sorted(bs, key=lambda x: (x["view"], x["column"])):
            rk = b["resolved_key"]
            hub = rk["hub"] or b["anchor"]
            expr = rk["expression"] or b.get("anchor_expression")
            i = byexpr.get((b["view"], hub, expr)) if (hub and expr) else None
            if i is None:
                continue
            col = N.attribute_column(b["attribute"])
            fl = E.emit_flag_name("%s_K%d" % (hub, i))
            parts.append(
                "    select\n"
                "        md5(upper(%s)) as %s,\n"
                "        /* REFUSED unless the decode is available: loading the raw code\n"
                "           into a LABEL attribute is wrong data that every gate passes. */\n"
                "        case when {{ var('%s', false) }}\n"
                "             then %s\n"
                "             else null\n"
                "        end as %s,\n"
                "        case when {{ var('%s', false) }}\n"
                "             then %s\n"
                "             else %s\n"
                "        end as DECODE_GATE_STATE,\n"
                "        %s as DECODE_SOURCE_COLUMN,\n"
                "        %s as DECODE_TARGET_ATTRIBUTE,\n"
                "        %s,\n"
                "        %s\n"
                "    from {{ ref('%s') }}\n"
                "    where %s"
                % (E.bk_name(hub, i), E.hk_name(hub),
                   VAR, N.quote_ident(b["column"]), col,
                   VAR, K.sql_literal("DECODED"), K.sql_literal("ROW_REFUSED_DECODE_ABSENT"),
                   K.sql_literal(b["column"]), K.sql_literal(b["attribute"]),
                   E.record_source(b["view"]), E.LOAD_DT,
                   N.stage_name(b["view"]), fl))
        if not parts:
            continue
        sql = "\n".join([
            E.config("view", ["tags=['reference_decode_gate']"]),
            E.header(GEN, [
                "%s  --  REFERENCE DECODE GATE (bespoke, declared)" % sat,
                "",
                "rows gated  : %d" % len(parts),
                "scope       : directive_kind == 'reference_decode' (the TYPED field added by",
                "              the round-2 map). transformation_kind == 'reference_decode' is",
                "              59 blocks and would over-apply this gate to 56 rows that carry",
                "              no directive.",
                "",
                "The row asserts code->decode and the TARGET is a human-readable LABEL, so",
                "loading raw puts a CODED value where a label belongs -- WRONG DATA, not",
                "absent data, and every gate passes it.",
                "",
                "DEFAULT IS REFUSE. No reference-decode master exists in this bundle, so the",
                "attribute is NULL and DECODE_GATE_STATE says why, on every row.",
                "TO OVERRULE (one line): set var %s to true." % VAR,
            ]),
            "",
            "with gated as (",
            "\n    union all\n".join(parts),
            ")",
            "",
            "select * from gated",
        ])
        E.write_model("reference_decode", N.refdecode_name(sat), sql, GEN)
        n += 1

    print("reference_decode gates emitted: %d  (BESPOKE, declared in the profile)" % n)
    print("  rows gated                  : %d  (UNIT=blocks, scoped by directive_kind)"
          % len(rows))
    print("  DEFAULT = REFUSE -- decision D1; one line to overrule (var %s)" % VAR)
    E.checkpoint("reference_decode", n, {"rows_gated": len(rows), "default": "REFUSE"})
    return n


if __name__ == "__main__":
    main()
