# -*- coding: utf-8 -*-
"""Casts for views that appear ANYWHERE on a walk, including intervening levels
no expression names.

THIS LAYER IS LOAD-BEARING ON THIS FEED AND WAS ZERO ON THE SIBLING. Only 52 of
1,812 climbs name the DIRECT parent; 1,760 skip at least one level. A generator
that cast only the views the map names would have no table to join at the skipped
levels, and the resolver would silently cross several levels in one join -- which
reads as sparse source data, not as an error.

OPUS Health needed 0 of these because it is flat (0 hierarchy edges). That is why
this layer is derived from the graph here and not inherited.
"""
import mxh3_emit as E
import mxh3_keyrules as K
import mxh3_names as N

GEN = "gen_mxh3_hopviews.py"


def main():
    sp = E.spec()
    hop = sp["views"]["hopviews"]
    named = set(sp["views"]["named_by_the_map"])
    n = no_map_row = 0
    for view in sorted(hop):
        d = hop[view]
        cols = [c for c in d["columns"] if c in K.view_columns(view)]
        if not cols:
            continue
        if view not in named:
            no_map_row += 1
        depth = K._index()["depth"].get(view)
        sql = "\n".join([
            E.config("view"),
            E.header(GEN, [
                "source view : %s" % view,
                "WALK-ONLY CAST: this view is on a walk; %s"
                % ("NO map row names it" if view not in named
                   else "a map row names it but it earned no staging cast"),
                "shred depth : %s" % depth,
                "columns     : %d (walk terminal columns + the spine lineage needed to"
                % len(cols),
                "              join one real level at a time)",
                "WHY         : only 52 of 1,812 climbs name the DIRECT parent, so every",
                "              intervening level must exist as a table to join through.",
                "convention  : %s (%s)" % (N.PAYLOAD_CONVENTION,
                                           N.PAYLOAD_CONVENTION_STATUS),
            ]),
            "",
            "select",
            ",\n".join("    " + E.cast(view, c) for c in cols),
            "from {{ source('%s', '%s') }}" % (E.SOURCE_NAME, view),
        ])
        E.write_model("hopviews", d["model"], sql, GEN)
        n += 1
    print("walk-only casts emitted      : %d" % n)
    print("  of those, NO map row names : %d  (UNIT=views, POPULATION=views on a walk)" % no_map_row)
    E.checkpoint("hopviews", n, {"with_no_map_row": no_map_row})
    return n


if __name__ == "__main__":
    main()
