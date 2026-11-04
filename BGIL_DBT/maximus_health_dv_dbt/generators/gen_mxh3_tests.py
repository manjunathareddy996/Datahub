# -*- coding: utf-8 -*-
"""Three LOAD-TIME assertions for questions no map-reading check can answer.

WE HAVE NO SOURCE ACCESS. Re-measured on this estate: no Oracle client on PATH, no
driver importable, no TNS/wallet/ODBC config, no env var, no dbt profile. So these
three questions CANNOT be answered here. What this layer does instead is make each
one FAIL LOUDLY AT FIRST LOAD rather than pass silently -- which is worth more than
a guess, because every one of the three is a SILENT failure mode today.

Each test states what it would prove and that NOTHING HAS BEEN EXECUTED.

A dbt test passes when it returns ZERO rows, so each model below selects the
OFFENDING rows.
"""
import collections

import mxh3_emit as E
import mxh3_keyrules as K
import mxh3_names as N

GEN = "gen_mxh3_tests.py"
NOT_EXECUTED = (
    "NOTHING HAS BEEN EXECUTED to produce this file. There is no source access in",
    "this environment (no Oracle client, driver, TNS/wallet/ODBC config, env var or",
    "dbt profile), so the question below is OPEN. This test converts it from a",
    "SILENT failure into a LOUD one at first load. A dbt test passes on zero rows,",
    "so this model selects the OFFENDING rows.",
)


def main():
    sp = E.spec()
    n = 0

    # ------------------------------------------------------------------ test 1
    # The 6 re-encoded HUB_CLAIM walks: an EMPTY JOIN is the silent failure.
    jp = [b for b in sp["blocks"] if b["resolved_key"]["join_path"]]
    views = sorted({b["view"] for b in jp})
    crosses = [s for s in sp["spans"] if s["kind"] == "cross"]
    parts = []
    for s in sorted(crosses, key=lambda x: x["ordinal"]):
        v = s["from_view"]
        if v not in sp["views"]["resolvers"]:
            continue
        col = N.fit("W%03d_%s" % (s["ordinal"], s["terminal_column"] or "VALUE"))
        cnt = N.fit("W%03d_N" % s["ordinal"])
        parts.append(
            "    select\n"
            "        %s as WALK,\n"
            "        %s as FROM_VIEW,\n"
            "        %s as TO_VIEW,\n"
            "        count(*) as SOURCE_ROWS,\n"
            "        count(%s) as RESOLVED_ROWS,\n"
            "        sum(case when %s > 1 then 1 else 0 end) as FANNED_OUT_ROWS\n"
            "    from {{ ref('%s') }}\n"
            "    having count(%s) = 0 or sum(case when %s > 1 then 1 else 0 end) > 0"
            % (K.sql_literal("W%03d" % s["ordinal"]), K.sql_literal(v),
               K.sql_literal(s["terminal_view"]), col, cnt,
               sp["views"]["resolvers"][v]["model"], col, cnt))
    if parts:
        sql = "\n".join([
            E.config("view", ["tags=['load_time_assertion','walk']"]),
            E.header(GEN, [
                "LOAD-TIME ASSERTION 1 of 3 -- WALKS THAT RETURN NO ROWS",
                "",
                "WHAT THIS WOULD PROVE: that each cross walk actually joins. An EMPTY JOIN",
                "is THE silent failure of this layer -- the key still renders, the model",
                "still compiles, and the hub simply loses those rows with no error anywhere.",
                "It is the defect that cost Health round 2.",
                "",
                "cross walks asserted : %d" % len(parts),
                "declared join_path   : %d block(s) on %d view(s)" % (len(jp), len(views)),
                "",
                "FAILS IF: a walk resolves ZERO rows (empty join), or ANY source row",
                "matched more than one row on the far side (a cross is 1:N, so the value",
                "was withheld and the rows were diverted -- see the reject log).",
            ] + list(NOT_EXECUTED)),
            "",
            "\nunion all\n".join(parts),
        ])
        E.write_model("tests", "assert_mxh3_walks_return_rows", sql, GEN)
        n += 1

    # ------------------------------------------------------------------ test 2
    # SAT_CLAIM_BENEFIT_HEAD: do the two head vocabularies intersect?
    OPUS_HEADS = ["TTD", "EMI", "FAMILY", "MED", "DEATH", "PTD", "CHILD", "TRANS",
                  "FUNERAL", "EDU", "CRITIC", "HOSP"]
    sat = "SAT_CLAIM_BENEFIT_HEAD"
    leg = "Benefit Head Code"
    ckcol = N.childkey_column(leg)
    if sat in sp["model"]["sat_attrs"]:
        sql = "\n".join([
            E.config("view", ["tags=['load_time_assertion','vocabulary']"]),
            E.header(GEN, [
                "LOAD-TIME ASSERTION 2 of 3 -- TWO HEAD VOCABULARIES IN ONE SATELLITE",
                "",
                "WHAT THIS WOULD PROVE: whether the 12 OPUS literal benefit head codes and",
                "the Maximus TEMPLATED column on %s resolve to the same" % sat,
                "vocabulary at runtime. Statically UNDECIDABLE: one side ENUMERATES values,",
                "the other NAMES the column the values come from.",
                "",
                "MEASURED STATICALLY on this feed: 47 blocks, 13 distinct child-key values,",
                "of which exactly ONE is a non-template literal -- 'TOTAL' -- and its",
                "intersection with the 12 OPUS heads is EMPTY. Concept agreement is 0 and",
                "the satellite is unsettled on BOTH feeds.",
                "",
                "FAILS IF: the loaded vocabulary INTERSECTS the 12 OPUS heads. Then two",
                "feeds are writing one vocabulary under different labels and must be",
                "unified BEFORE load. If it stays empty, one ratified Multi-Active SCD2",
                "satellite carries two coexisting head vocabularies -- which must be a",
                "CONSCIOUS decision rather than an accident.",
                "",
                "the 12 OPUS heads: %s" % ", ".join(OPUS_HEADS),
            ] + list(NOT_EXECUTED)),
            "",
            "select",
            "    %s as HEAD_CODE," % ckcol,
            "    count(*) as ROWS_LOADED,",
            "    %s as INTERSECTS_OPUS_LITERAL_HEADS" % K.sql_literal("YES"),
            "from {{ ref('%s') }}" % N.sat_name(sat),
            "where upper(%s) in (%s)" % (ckcol,
                                         ", ".join(K.sql_literal(h) for h in OPUS_HEADS)),
            "group by %s" % ckcol,
        ])
        E.write_model("tests", "assert_mxh3_benefit_head_vocabulary", sql, GEN)
        n += 1

    # ------------------------------------------------------------------ test 3
    # SRM-COVERGRAIN: N rows per claim writing ONE row of a claim-grained satellite.
    cg = collections.defaultdict(set)
    for b in sp["blocks"]:
        if "LIST_OF_COVERS" in b["view"] and b["home"]:
            if sp["model"]["sat_childkey"].get(b["home"], "") == "":
                cg[b["home"]].add(b["view"])
    targets = {s: sorted(v) for s, v in cg.items() if s in sp["model"]["sat_attrs"]}
    parts = []
    for sat2, views2 in sorted(targets.items()):
        hub = sp["model"]["sat_parent"].get(sat2)
        if not hub:
            continue
        attrs = [N.attribute_column(a) for a in sp["model"]["sat_attrs"][sat2]]
        hk = E.hk_name(hub)
        probe = attrs[0] if attrs else None
        if probe is None:
            continue
        parts.append(
            "    select\n"
            "        %s as SATELLITE,\n"
            "        %s as ANCHOR_HASH_KEY,\n"
            "        count(*) as ROWS_PER_ANCHOR,\n"
            "        count(distinct %s) as DISTINCT_VALUES\n"
            "    from {{ ref('%s') }}\n"
            "    group by %s\n"
            "    having count(distinct %s) > 1"
            % (K.sql_literal(sat2), hk, probe, N.sat_name(sat2), hk, probe))
    if parts:
        sql = "\n".join([
            E.config("view", ["tags=['load_time_assertion','grain']"]),
            E.header(GEN, [
                "LOAD-TIME ASSERTION 3 of 3 -- SRM-COVERGRAIN, VALUES DIFFERING PER COVER",
                "",
                "WHAT THIS WOULD PROVE: whether the 35 blocks on 2 views under LIST_OF_COVERS",
                "carry values that DIFFER per cover. The sampled shred shows one CLAIM_DETAIL",
                "node with 5 and 8 descendant nodes, so N rows per claim write ONE row of a",
                "CLAIM-GRAINED single-active satellite. Whether those N rows differ needs",
                "executed data.",
                "",
                "satellites asserted: %d -- %s" % (len(parts), ", ".join(sorted(targets))),
                "",
                "FAILS IF: more than one DISTINCT value reaches one anchor. Then the",
                "satellite is silently keeping one arbitrary cover's values.",
                "",
                "THIS IS INVISIBLE TO EVERY OTHER CHECK HERE: check_collapse sees no",
                "column-level fan-in because each column writes a DIFFERENT attribute, and",
                "the grain sweep asked a model-conformance question these rows satisfy.",
            ] + list(NOT_EXECUTED)),
            "",
            "\nunion all\n".join(parts),
        ])
        E.write_model("tests", "assert_mxh3_covergrain_value_divergence", sql, GEN)
        n += 1

    print("load-time assertions emitted : %d of 3" % n)
    print("  runtime verdict            : NOT RUN -- no source access in this environment")
    print("  each test names what it would prove and that nothing was executed")
    E.checkpoint("tests", n, {"runtime_verdict": "NOT RUN -- no source access",
                              "static_only": True})
    return n


if __name__ == "__main__":
    main()
