# -*- coding: utf-8 -*-
"""Layer 1: typed casts for views that NEED one.

s6.1 -- a view gets a cast because it NEEDS one, not because it is in the map.
A view earns a staging model by supplying at least one column that an emitted
model actually references: a payload attribute, a key operand, a child-key
operand, or a walk terminal column. Two of the 85 views the map names supply
none and are reported as skipped rather than emitted empty.
"""
import mxh3_emit as E
import mxh3_keyrules as K
import mxh3_names as N

GEN = "gen_mxh3_staging.py"


def main():
    sp = E.spec()
    staging = sp["views"]["staging"]
    named = set(sp["views"]["named_by_the_map"])
    n = 0
    for view in sorted(staging):
        d = staging[view]
        cols = [c for c in d["columns"] if c in K.view_columns(view)]
        if not cols:
            continue
        lineage = [c for c in cols if c in
                   ("KEY_HASH", "PARENT_KEY_HASH", "FOREIGN_KEY", "RECORD_HASH",
                    "ROOT_HASH", "PARENT_RECORD_HASH", "PARENT_TABLE_NAME")]
        sql = "\n".join([
            E.config("view"),
            E.header(GEN, [
                "source view : %s" % view,
                "cast reason : %s" % d["reason"],
                "columns     : %d of %d on the view (a view gets a cast because it NEEDS"
                % (len(cols), len(K.view_columns(view))),
                "              one, not because it is in the map)",
                "lineage     : %d spine column(s) retained: %s"
                % (len(lineage), ", ".join(lineage) or "none"),
                "convention  : %s (%s)" % (N.PAYLOAD_CONVENTION,
                                           N.PAYLOAD_CONVENTION_STATUS),
                "pivot view  : %s" % ("yes -- shredded EAV" if K.is_pivot(view) else "no"),
            ]),
            "",
            "select",
            ",\n".join("    " + E.cast(view, c) for c in cols),
            "from {{ source('%s', '%s') }}" % (E.SOURCE_NAME, view),
        ])
        E.write_model("staging", d["model"], sql, GEN)
        n += 1

    skipped = sorted(named - set(staging))
    print("staging casts emitted        : %d" % n)
    print("  views named by the map     : %d" % len(named))
    print("  SKIPPED, with the reason   : %d" % len(skipped))
    for v in skipped:
        print("     %s -- supplies no column any emitted model references, so a cast would "
              "be empty" % v[-70:])
    E.checkpoint("staging", n, {"skipped_views": len(skipped),
                                "skipped_reason": "supplies no referenced column"})
    return n


if __name__ == "__main__":
    main()
