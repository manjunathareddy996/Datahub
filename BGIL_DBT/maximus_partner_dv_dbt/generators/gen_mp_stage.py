# -*- coding: utf-8 -*-
"""Layer 2: ONE WIDE stage() per source view.

One model per view carries every hub/link key that view resolves, plus a HASHDIFF_<SAT> and the
payload for every SINGLE-ACTIVE satellite on it. Multi-active satellites are fed by the unpivot
layer instead -- that is the only layer that defines a child key.

A link's key is composed here from its legs' business keys (mp_keyrules.LINK_LEGS): the map keys
the legs and never the link, so reading a link key out of the map is what left all four unbuilt on
travel until round 3.
"""
import collections
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mp_names as N
import mp_keyrules as K

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
SRC = os.path.join(ROOT, "maximum_partner")
STD = os.path.join(ROOT, "maximus_partner_dv_dbt", "models", "automate_dv", "standard")
spec = json.load(open(os.path.join(SRC, "_mp_spec.json"), encoding="utf-8"))

for f in os.listdir(os.path.join(STD, "staging")):
    if f.startswith("stg2_mp__"):
        os.remove(os.path.join(STD, "staging", f))

# a satellite's payload is the UNION across every view, so each feeder is union-compatible
SAT_PAYLOAD = collections.defaultdict(set)
for v in spec.values():
    for s, r in v["sats"].items():
        SAT_PAYLOAD[s] |= {N.attr_col(a) for a in r["payload"]}

n = 0
skipped = collections.Counter()
for tbl, v in sorted(spec.items()):
    model = v["model"]
    cols = {c.lower() for c in v["all_cols"]} | K.SPINE_COLS
    keys = {}
    for a, k in v["keys"].items():
        if K.is_child_key_tier(k.get("tier"), k.get("rule")):
            continue
        e = K.key_expr(a, k.get("tier"), k.get("rule"), cols, tbl, address=v["addr"])
        if e:
            keys[a] = e

    # A link whose rule SPELLS OUT each leg (same-hub links) gets one key per named leg, so the
    # two legs cannot collapse onto one column.
    legcols = {}
    for lnk, k in v["keys"].items():
        if not lnk.startswith("LNK_"):
            continue
        named = K.link_legs_from_rule(k.get("rule") or "")
        if len(named) < 2:
            continue
        exprs = []
        for col, tier, txt in named:
            e = K.key_expr("HUB_" + re.sub(r"^RELATED_", "", col), tier, txt, cols, tbl,
                           address=v["addr"])
            if e:
                legcols[col] = e
                exprs.append(e)
        if len(exprs) == len(named):
            keys[lnk] = " || '||' || ".join(f"({e})" for e in exprs)

    # otherwise a LINK's key is the composition of its legs, wherever this view keys every leg
    for lnk, legs in K.LINK_LEGS.items():
        if lnk in v["keys"] and lnk not in keys and all(l in keys for l in legs):
            keys[lnk] = " || '||' || ".join(f"({keys[l]})" for l in legs)

    if not keys:
        skipped["no resolvable key on the view"] += 1
        continue

    hashed, derived = {}, {}
    for col, e in sorted(legcols.items()):        # the named legs of a same-hub link
        hashed[f"{col}_HKEY"] = f"{col}_NK"
        derived[f"{col}_BK"] = e
        derived[f"{col}_NK"] = f"'HUB_{re.sub(r'^RELATED_', '', col)}|' || ({e})"
    for a, e in sorted(keys.items()):
        base = re.sub(r"^(HUB|LNK)_", "", a)
        hashed[f"{base}_HKEY"] = f"{base}_NK"
        derived[f"{base}_BK"] = e
        derived[f"{base}_NK"] = f"'{a}|' || ({e})"

    for s, r in sorted(v["sats"].items()):
        if r["ma"] and r["cdk"]:
            continue                       # the unpivot layer owns multi-active satellites
        if r["anchor"] not in keys:
            skipped["satellite anchor has no key on this view"] += 1
            continue
        hashed["HASHDIFF_" + s.replace("SAT_", "", 1).upper()] = sorted(SAT_PAYLOAD[s])
        for a, lst in r["payload"].items():
            live = [x for x in lst if not x.get("redundant_of")]
            col = N.attr_col(a)
            if live:
                # more than one source column for one attribute -> coalesce, never a second column
                derived[col] = (N.ident(live[0]["col"]) if len(live) == 1 else
                                "coalesce(" + ", ".join(N.ident(x["col"]) for x in live) + ")")
        for p in SAT_PAYLOAD[s]:
            derived.setdefault(p, "cast(null as varchar)")

    L = ["{{ config(materialized='view') }}", "",
         f"-- MAXIMUS PARTNER wide stage() for {tbl}.",
         f"-- {len(keys)} key(s), {sum(1 for h in hashed if h.startswith('HASHDIFF_'))} "
         "single-active satellite(s).", "",
         "{%- set yaml_metadata -%}", f"source_model: 'stg_maximus__{model}'", "hashed_columns:"]
    for h, val in hashed.items():
        if isinstance(val, list):
            L += [f"  {h}:", "    is_hashdiff: true", "    columns:"]
            L += [f"      - '{c}'" for c in val]
        else:
            L.append(f"  {h}: '{val}'")
    L.append("derived_columns:")
    L += [f'  {k}: "{e}"' for k, e in derived.items()]
    L += ["  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'", f"  RECORD_SOURCE: '!{tbl}'",
          "{%- endset -%}", "", "{% set metadata_dict = fromyaml(yaml_metadata) %}", "",
          "{{ automate_dv.stage(include_source_columns=false,",
          "                     source_model=metadata_dict['source_model'],",
          "                     hashed_columns=metadata_dict['hashed_columns'],",
          "                     derived_columns=metadata_dict['derived_columns']) }}", ""]
    open(os.path.join(STD, "staging", N.stage_name(model) + ".sql"), "w",
         encoding="utf-8").write("\n".join(L))
    n += 1

print(f"wide stage models : {n}")
for k, c in skipped.most_common():
    print(f"  skipped: {c}  {k}")
for u in K.UNRESOLVED:
    print(f"  !! {N.model_name(u[0])[:26]:28s} {u[1]:24s} {u[3]}")
