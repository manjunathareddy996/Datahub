# -*- coding: utf-8 -*-
"""One row per INSTANCE, for column-as-instance families only.

This feed is a shredded EAV source: 53 of 188 index tables are is_pivot. Where N
source columns on one view all write the SAME attribute of the SAME satellite
under DIFFERENT child-key values, those columns are not N attributes -- they are
N INSTANCES of one attribute, and they must become N ROWS.

Emitting them as N columns on one row is precisely the sibling defect recorded
during calibration: sat_claim_disability_head there emits five columns all aliased
DISABILITY_TYPE_CODE inside one select, which is a multi-active child key rendered
as N columns on one row instead of N rows. This layer is why that cannot happen
here.

ONLY column-as-instance families are unpivoted. A view is not unpivoted because it
is a pivot view; it is unpivoted because a family was MEASURED on it.
"""
import mxh3_emit as E
import mxh3_keyrules as K
import mxh3_names as N

GEN = "gen_mxh3_unpivot.py"


def main():
    sp = E.spec()
    unp = sp["views"]["unpivot"]
    n = rows = fams = 0
    for view in sorted(unp):
        d = unp[view]
        families = d["families"]
        src = (sp["views"]["staging"].get(view) or sp["views"]["hopviews"].get(view))
        if src is None:
            continue
        branches = []
        for f in families:
            fams += 1
            for m in f["members"]:
                if m["column"] not in K.view_columns(view):
                    continue
                rows += 1
                branches.append(
                    "select\n"
                    "    src.*,\n"
                    "    %s as INSTANCE_CHILD_KEY_SOURCE,\n"
                    "    %s as INSTANCE_COLUMN,\n"
                    "    %s as INSTANCE_SATELLITE,\n"
                    "    %s as INSTANCE_ATTRIBUTE,\n"
                    "    %s as INSTANCE_VALUE\n"
                    "from src"
                    % (K.sql_literal(m["child_key"]), K.sql_literal(m["column"]),
                       K.sql_literal(f["satellite"]), K.sql_literal(f["attribute"]),
                       N.quote_ident(m["column"])))
        if not branches:
            continue
        sql = "\n".join([
            E.config("view"),
            E.header(GEN, [
                "source view : %s" % view,
                "is_pivot    : %s" % K.is_pivot(view),
                "families    : %d column-as-instance family/families on this view"
                % len(families),
                "branches    : %d -- ONE ROW PER INSTANCE, not N columns on one row"
                % len(branches),
                "",
                "A family is (satellite, attribute) reached by >1 source column on this",
                "view under DIFFERENT child-key values. Emitting those as N columns in one",
                "select is a multi-active child key flattened onto one row -- the defect",
                "observed in the calibration sibling's own built SQL.",
            ] + ["family: %-34s . %-28s members=%d"
                 % (f["satellite"], f["attribute"], len(f["members"]))
                 for f in families[:8]]),
            "",
            "with src as (select * from {{ ref('%s') }})" % src["model"],
            "",
            "\nunion all\n\n".join(branches),
        ])
        E.write_model("unpivot", d["model"], sql, GEN)
        n += 1

    print("unpivot models emitted       : %d" % n)
    print("  families                   : %d  (UNIT=(satellite,attribute) on a view)" % fams)
    print("  instance branches          : %d  (UNIT=rows emitted per source row)" % rows)
    E.checkpoint("unpivot", n, {"families": fams, "instance_branches": rows})
    return n


if __name__ == "__main__":
    main()
