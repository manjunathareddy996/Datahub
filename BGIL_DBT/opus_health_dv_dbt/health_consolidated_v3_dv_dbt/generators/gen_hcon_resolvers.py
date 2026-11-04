# -*- coding: utf-8 -*-
"""ANCESTOR RESOLVERS -- one resolver per START VIEW, joins expanded per REAL level.
health_consolidated.

THIS LAYER IS EMPTY, AND THE ZERO IS PROVEN RATHER THAN OMITTED.

A resolver exists to climb a declared hierarchy: when an expression names a destination several
levels up, the resolver joins ONE LEVEL AT A TIME, because a named destination may skip levels and
a single join to the named level silently loses every row whose chain is shorter (BUILD_RULES.md
s4). None of that applies here, and the reason is measured, not remembered.

TWO independent measurements, both reported:
  1. zero walk operators over every key-bearing string in the map (see gen_hcon_hopviews);
  2. zero edge/parent fields at any level of the map -- there is no field naming a parent row, so
     there is no hierarchy to climb even if an operator had appeared.

Measurement 2 matters on its own: the profile records that STEP 3's edge-field hunt was NOT RUN,
because the grammar census had already found no walk operator. That is a sound reason to skip it
upstream and a bad reason for a BUILDER to skip it, so it is run here.
"""
import collections
import json
import os
import sys

import hcon_keyrules as K
from hcon_writeguard import PROJECT_ROOT

SPEC_PATH = os.path.join(PROJECT_ROOT, "build_artifacts", "hcon_spec.json")

# Field names that would carry an edge -- a pointer from one row to a parent row. Swept as a SET;
# a member found present means a hierarchy exists and this layer must be built.
EDGE_FIELD_TOKENS = ("parent_key", "parent_hash", "parent_key_hash", "parent_id", "parent_row",
                     "foreign_key", "fk", "ancestor", "spine", "hierarchy", "level", "depth",
                     "parent_bk", "edge", "path")


def sweep_edge_fields(rows):
    """Every field NAME at every level, tested against the edge-field vocabulary."""
    names = collections.Counter()

    def walk(o, prefix):
        if isinstance(o, dict):
            for k, v in o.items():
                names[("%s.%s" % (prefix, k)).lstrip(".")] += 1
                walk(v, "%s.%s" % (prefix, k))
        elif isinstance(o, list):
            for item in o:
                walk(item, prefix + "[]")

    for r in rows:
        walk(r, "")
    hits = {}
    for name, n in names.items():
        leaf = name.split(".")[-1].replace("[]", "").lower()
        for tok in EDGE_FIELD_TOKENS:
            if tok == leaf or leaf.endswith("_" + tok) or leaf.startswith(tok + "_"):
                hits[name] = n
    return names, hits


def main():
    with open(SPEC_PATH, encoding="utf-8") as fh:
        spec = json.load(fh)
    rows = K.load_map()
    names, hits = sweep_edge_fields(rows)
    if hits:
        raise AssertionError(
            "EDGE FIELD(S) PRESENT in the map: %s -- a hierarchy exists, so the resolver layer "
            "must be built and every hop expanded into its REAL per-level chain (s4). Refusing to "
            "emit an empty layer over a map that has levels." % hits)
    print("[resolvers] ancestor resolvers: 0 models.")
    print("[resolvers] THE ZERO IS PROVEN TWICE, not assumed:")
    print("[resolvers]   1. walk operators over every key-bearing string: %s"
          % spec["meta"]["walk_operator_counts"])
    print("[resolvers]   2. edge fields over EVERY field name at EVERY level: 0 hits against a "
          "%d-token vocabulary, swept over %d distinct field paths in %d rows"
          % (len(EDGE_FIELD_TOKENS), len(names), len(rows)))
    print("[resolvers] MATCHER for 2 = leaf field name equals a token, or ends with '_<token>', "
          "or starts with '<token>_'; UNIT = distinct dotted field path; POPULATION = all %d rows."
          % len(rows))
    print("[resolvers] profile.hierarchy_walk_note records that the upstream edge-field hunt was "
          "NOT RUN. It is run here, because 'the operator census was zero' is a sound reason to "
          "skip it upstream and a bad reason for a builder to skip it.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
