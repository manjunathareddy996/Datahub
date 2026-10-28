# -*- coding: utf-8 -*-
"""gen_mtv2_resolvers.py -- one resolver per START VIEW, carrying every ancestor or relative
column that view's expressions need.

Every hop is expanded into a REAL per-level chain off the shred spine
(PARENT_KEY_HASH -> parent.KEY_HASH), taken from 00_tables_index.json's parent pointer and never
from the destination's name: 772 PARENT_KEY_HASH hops in this bundle name a destination that
skips a level, and joining straight to the name loses the intervening rows.

Two things go wrong here and both are SILENT: a duplicate join hash fans every child join out,
and a child that finds no parent drops out of its satellite and reads as 'no data'. Neither shows
up in a dependency sweep or a src_pk check. Left joins throughout, so a row whose ancestor is
missing keeps its own columns and resolves the walk to NULL -- where render_key()'s CASE guard
drops it from the hub feed and the drop is COUNTED (audit layer) rather than inferred.
"""
import collections
import json
import os
import sys

import mtv2_names as N
import mtv2_keyrules as K
import build_mtv2_spec as S

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass


def resolver_body(view, info):
    walks = info["walks"]
    short = info["short"]
    base = N.model_name("cast", view)

    selects = ["    b.*"]
    joins = []
    notes = []
    counts = collections.Counter()
    for w in walks:
        alias = w["alias"]
        chain = w["chain"]
        counts[w["relation"]] += 1
        if not chain:
            # the expression named this very view as the destination: the column is on the row.
            selects.append("    b.%s as %s" % (N.cast_alias(w["column"]), alias))
            notes.append("--   %-24s on this view (the walk names the start view itself)" % alias)
            continue
        if w["join_column"] == "FOREIGN_KEY":
            tgt = chain[-1]
            t_alias = "%s_d" % alias
            joins.append("left join {{ ref('%s') }} %s\n    on %s.foreign_key = b.foreign_key"
                         % (N.model_name("cast", tgt), t_alias, t_alias))
            selects.append("    %s.%s as %s" % (t_alias, N.cast_alias(w["column"]), alias))
            notes.append("--   %-24s fk_join (document handle) => %s.%s"
                         % (alias, N.short_view(tgt), w["column"]))
            continue
        prev = "b"
        for depth, step in enumerate(chain):
            t_alias = "%s_p%d" % (alias, depth)
            joins.append("left join {{ ref('%s') }} %s\n    on %s.key_hash = %s.parent_key_hash"
                         % (N.model_name("cast", step), t_alias, t_alias, prev))
            prev = t_alias
        selects.append("    %s.%s as %s" % (prev, N.cast_alias(w["column"]), alias))
        notes.append("--   %-24s %s hop, %d real level(s): %s . %s"
                     % (alias, w["relation"], len(chain),
                        " -> ".join(N.short_view(c) for c in chain), w["column"]))

    header = [
        "{{ config(materialized='view') }}",
        "",
        "-- RESOLVER for %s" % view,
        "--",
        "-- Carries %d walk column(s) onto each row of %s." % (len(walks), base),
        "-- Every hop below is expanded from the SOURCE INDEX's parent pointer, not from the",
        "-- destination's name: a named destination skips levels.",
        "--",
    ] + notes + [
        "--",
        "-- Left joins throughout. A row whose ancestor is missing keeps its own columns and",
        "-- resolves the walk to NULL; render_key()'s guard then drops it from the hub feed and",
        "-- audit_mtv2_key_rejections counts the drop. A WRONG hop would also produce all-NULL,",
        "-- which is why the drop is counted per hub per feeder rather than assumed to be zero.",
    ]
    if counts.get("fk_join"):
        header += [
            "--",
            "-- %d hop(s) here join on FOREIGN_KEY, the document handle (BD1). The round-trip to"
            % counts["fk_join"],
            "-- the root business number is UNPROVEN -- 00_tables_index.json carries",
            "-- sample_data_available=false -- so audit_mtv2_fk_roundtrip counts distinct root",
            "-- business numbers per FOREIGN_KEY value; any count above 1 falsifies it before any",
            "-- load (open item P6-FK-ROUNDTRIP).",
        ]
    if counts.get("lca_cross"):
        header += [
            "--",
            "-- %d hop(s) here are a LOWEST-COMMON-ANCESTOR CROSS, not a climb: the destination is"
            % counts["lca_cross"],
            "-- a SIBLING. A climb-only resolver returns nothing for these and the miss reads",
            "-- downstream as a source gap that is not there.",
        ]

    return "\n".join(header + ["", "select", ",\n".join(selects),
                              "from {{ ref('%s') }} b" % base] + joins)


def schema_yml(entries):
    out = ["version: 2", "",
           "# Guardrails for the spine-join key layer. The two failures here are both SILENT: a",
           "# duplicate join hash fans every child join out, and a child that finds no parent",
           "# drops out of its satellite and reads as 'no data'. Documented per walk so the next",
           "# reader can see what each column is supposed to reach.", "", "models:"]
    for name, view, walks in entries:
        out.append("  - name: %s" % name)
        out.append("    description: >")
        out.append("      %d walk column(s) onto %s." % (len(walks), N.short_view(view)))
        out.append("    columns:")
        for w in walks:
            out.append("      - name: %s" % w["alias"])
            out.append("        description: >")
            dest = N.short_view(w["destination"]) if w["chain"] else N.short_view(view)
            out.append("          %s hop to %s.%s%s"
                       % (w["relation"], dest, w["column"],
                          " (SIBLING cross: 1:N in the general case)"
                          if w["relation"] == "lca_cross" else ""))
    return "\n".join(out)


def main():
    with open(S.SPEC_PATH, encoding="utf-8") as fh:
        spec = json.load(fh)
    stale = N.wipe_layer("resolver")
    print("gen_mtv2_resolvers: wiped %d stale file(s)" % stale)
    entries, counts = [], collections.Counter()
    for view in spec["cast_views"]:
        info = spec["views"][view]
        if not info["walks"]:
            counts["no_walks_no_resolver"] += 1
            continue
        name = N.model_name("resolver", view)
        N.write_model(N.model_path("resolver", name), resolver_body(view, info))
        entries.append((name, view, info["walks"]))
        counts["resolvers"] += 1
        for w in info["walks"]:
            counts["walk_" + w["relation"]] += 1
            if len(w["chain"]) > 1:
                counts["walks_over_expanded_levels"] += 1
                counts["levels_expanded"] += len(w["chain"]) - 1
    N.write_model(os.path.join(N.LAYER_DIRS["resolver"], "_mtv2_resolvers.yml"),
                  schema_yml(entries))

    print("gen_mtv2_resolvers: %d resolver(s)" % counts["resolvers"])
    print("  views with a cast but NO walk (they read the cast directly): %d"
          % counts["no_walks_no_resolver"])
    print("  distinct walk columns by relation:")
    for k in sorted(counts):
        if k.startswith("walk_"):
            print("      %-16s %d" % (k[5:], counts[k]))
    print("  walks whose join chain crosses a level the destination SKIPPED: %d "
          "(%d intervening level(s))"
          % (counts["walks_over_expanded_levels"], counts["levels_expanded"]))
    print("  Sizing the join chain from the NAMED destination alone would have emitted %d fewer"
          % counts["levels_expanded"])
    print("  joins and silently returned the wrong ancestor row.")


if __name__ == "__main__":
    main()
