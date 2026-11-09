# -*- coding: utf-8 -*-
"""The reject log: divert-and-COUNT. THE LARGEST OBLIGATION ON THIS FEED.

2,100 key blocks carry degenerate_verdict 'null_on_blank_row'. On Snowflake
'MEMBER:' || nullif(trim(X),'') is NULL when X is blank, and a NULL key is DROPPED
by the load. That is unlogged data loss which reads as a sparse source: no error,
no count, nothing to find later. 326 more render '' rather than NULL, which the
load accepts as a business key.

So every row that fails a key's emit predicate is diverted HERE, with its reason,
and counted.

THE COMPLEMENT ASSERTION. For each slot the stage emits
    case when P then true else false end as <slot>__EMIT
and this model selects
    not (P)
with P the IDENTICAL predicate text. The pair is therefore an exact boolean
complement BY CONSTRUCTION, asserted again here per slot: a row is emitted or
rejected, never both and never neither.

THE ONE ACCEPTED CONSTANT. The single constant_on_blank_row block has NO source
operand ('COV:' || 'CRITICAL_ILLNESS'), so it is constant by construction and is
ACCEPTED: its emit predicate is the literal `true` and its reject predicate is
`not (true)`, which is never satisfied. A rule phrased "reject any constant key"
would drop every row on that view.
"""
import collections

import mxh3_emit as E
import mxh3_keyrules as K
import mxh3_names as N
from gen_mxh3_stage import key_slots

GEN = "gen_mxh3_rejectlog.py"


def main():
    sp = E.spec()
    slots = key_slots(sp)
    by_view = collections.defaultdict(list)
    for (view, hub, i), d in slots.items():
        by_view[view].append((hub, i, d))

    n = branches = 0
    cls = collections.Counter()
    accepted_constants = 0
    for view in sorted(by_view):
        stage = N.stage_name(view)
        parts = []
        for hub, i, d in sorted(by_view[view], key=lambda x: (x[0], x[1])):
            emit, reject = d["emit"], d["reject"]
            K.assert_complement(emit, reject)      # asserted PER SLOT, every slot
            cls[d["reject_class"]] += 1
            if emit == "true":
                accepted_constants += 1
                continue                            # cannot be rejected, by design
            parts.append(
                "select\n"
                "    %s as REJECT_HUB,\n"
                "    %s as REJECT_SLOT,\n"
                "    %s as REJECT_CLASS,\n"
                "    %s as REJECT_VIEW,\n"
                "    %s as REJECT_PREDICATE,\n"
                "    src.*,\n"
                "    %s\n"
                "from src\n"
                "where %s"
                % (K.sql_literal(hub), K.sql_literal(E.bk_name(hub, i)),
                   K.sql_literal(d["reject_class"]), K.sql_literal(view),
                   K.sql_literal(reject), E.LOAD_DT, reject))
            branches += 1
        if not parts:
            continue
        sql = "\n".join([
            E.config("view"),
            E.header(GEN, [
                "source view : %s" % view,
                "stage       : %s" % stage,
                "reject branches: %d (one per key slot that CAN be rejected)" % len(parts),
                "",
                E.ENGINE_NOTE,
                "",
                "Each WHERE below is `not (P)` with P the IDENTICAL predicate the stage",
                "uses to emit. The pair is an exact boolean complement BY CONSTRUCTION,",
                "and assert_complement re-checks every slot at generation time.",
                "A row is emitted or rejected -- never both, never neither.",
            ]),
            "",
            "with src as (select * from {{ ref('%s') }})" % stage,
            "",
            "\nunion all\n\n".join(parts),
        ])
        E.write_model("reject_log", N.reject_name(view), sql, GEN)
        n += 1

    print("reject logs emitted          : %d" % n)
    print("  reject branches            : %d  (UNIT=key slots that can be rejected)" % branches)
    print("  accepted constant slots    : %d  (no source operand -> ACCEPTED, never rejected)"
          % accepted_constants)
    print("  by reject class (UNIT=slots):")
    for k, v in sorted(cls.items()):
        print("     %-46s %d" % (k, v))
    E.checkpoint("reject_log", n, {"branches": branches,
                                   "accepted_constants": accepted_constants,
                                   "by_class": dict(cls)})
    return n


if __name__ == "__main__":
    main()
