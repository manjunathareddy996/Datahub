# -*- coding: utf-8 -*-
"""Layer 2b: the multi-active satellites -- an unpivot view per (view, satellite), then a stage().

One row PER INSTANCE, never per column. Grouping branches by column instead of by instance is what
shredded eight address fields into eight rows sharing one child key on maximus_health.

The child key value is the mapper's own `child_key_value` / `instance`, which keeps this in the
same vocabulary partner_dv_dbt already writes. A derived column NAME would put two vocabularies in
one shared table.
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

for d in ("unpivot",):
    for f in os.listdir(os.path.join(STD, d)):
        os.remove(os.path.join(STD, d, f))
for f in os.listdir(os.path.join(STD, "staging")):
    if f.startswith("stg2_mp_up__"):
        os.remove(os.path.join(STD, "staging", f))

SAT_PAYLOAD = collections.defaultdict(set)
for v in spec.values():
    for s, r in v["sats"].items():
        SAT_PAYLOAD[s] |= {N.attr_col(a) for a in r["payload"]}


def ck_value(x):
    for k in ("child_key_value", "instance"):
        val = (x.get(k) or "").strip()
        if val and val != "-":
            return val
    return None


n_up = n_st = 0
skipped = collections.Counter()
for tbl, v in sorted(spec.items()):
    model = v["model"]
    cols = {c.lower() for c in v["all_cols"]} | K.SPINE_COLS
    for sat, r in sorted(v["sats"].items()):
        if not (r["ma"] and r["cdk"]):
            continue
        k = v["keys"].get(r["anchor"]) or {}
        if K.is_child_key_tier(k.get("tier"), k.get("rule")):
            k = {}
        bk = (K.key_expr(r["anchor"], k.get("tier"), k.get("rule"), cols, tbl, address=v["addr"])
              if k else (("foreign_key") if r["anchor"] in K.ROOT_ANCHORS else None))
        if bk is None:
            skipped[f"no hub key on this view ({r['anchor']})"] += 1
            continue

        # group by INSTANCE, not by column
        groups = collections.defaultdict(dict)
        no_label = []
        for attr, lst in r["payload"].items():
            for x in lst:
                if x.get("redundant_of"):
                    continue               # a synonym coalesced into its surviving writer
                cv = ck_value(x)
                if cv is None:
                    no_label.append((attr, x["col"]))
                    continue
                groups[cv][attr] = x
        if not groups:
            skipped[f"multi-active but no instance label ({sat})"] += 1
            continue

        allpay = sorted(SAT_PAYLOAD[sat])
        paycol = {N.attr_col(a): a for a in r["payload"]}
        short = re.sub(r"^SAT_", "", sat).lower()
        name = N.unpivot_name(model, short)
        base = re.sub(r"^(HUB|LNK)_", "", r["anchor"])

        branches = []
        for inst in sorted(groups):
            members = groups[inst]
            sel = [f"        {bk} as parent_bk"]
            done = set()
            for i, c in enumerate(r["cdk"]):
                a = paycol.get(c)
                y = members.get(a) if a else None
                if y is not None:
                    # a child key that IS one of the satellite's attributes is ONE column, valued
                    # from its source -- never a literal beside a second column of the same name
                    sel.append(f"        {N.ident(y['col'])} as {c.lower()}")
                    done.add(a)
                else:
                    sel.append(f"        {N.sql_str(inst if i == 0 else '1')} as {c.lower()}")
                    if a:
                        done.add(a)
            for p in allpay:
                a = paycol.get(p)
                if a in done:
                    continue
                y = members.get(a) if a else None
                sel.append(f"        {N.ident(y['col'])} as {p.lower()}" if y
                           else f"        cast(null as varchar) as {p.lower()}")
            sel.append(f"        {N.sql_str(tbl)} as record_source")
            guard = " or ".join(
                f"nullif(trim(to_varchar({N.ident(y['col'])})), '') is not null"
                for y in members.values())
            branches.append("    select\n" + ",\n".join(sel) +
                            f"\n    from {{{{ ref('stg_maximus__{model}') }}}}\n    where {guard}")

        open(os.path.join(STD, "unpivot", name + ".sql"), "w", encoding="utf-8").write(
            "{{ config(materialized='view') }}\n\n"
            f"-- UNPIVOT for {sat} from {tbl}\n"
            f"-- {len(branches)} row(s), ONE PER INSTANCE of {' + '.join(r['cdk'])}.\n"
            "-- The instance label is the mapper's own child_key_value, which keeps this in the\n"
            "-- vocabulary partner_dv_dbt already writes.\n\n"
            + "\n    union all\n".join(branches) + "\n")
        n_up += 1
        if no_label:
            skipped[f"column with no instance label on a multi-active sat"] += len(no_label)

        hd = "HASHDIFF_" + sat.replace("SAT_", "", 1).upper()
        L = ["{{ config(materialized='view') }}", "",
             f"-- stage() over the {sat} unpivot for {tbl}: one hashing pass over all "
             f"{len(branches)} rows.", "",
             "{%- set yaml_metadata -%}", f"source_model: '{name}'", "hashed_columns:",
             f"  {r['src_pk']}: '{base}_NK'", f"  {hd}:", "    is_hashdiff: true", "    columns:"]
        L += [f"      - '{p}'" for p in allpay]
        L += ["derived_columns:", f'  {base}_BK: "parent_bk"',
              f'  {base}_NK: "\'{r["anchor"]}|\' || (parent_bk)"',
              "  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'", "{%- endset -%}", "",
              "{% set metadata_dict = fromyaml(yaml_metadata) %}", "",
              "{{ automate_dv.stage(include_source_columns=true,",
              "                     source_model=metadata_dict['source_model'],",
              "                     hashed_columns=metadata_dict['hashed_columns'],",
              "                     derived_columns=metadata_dict['derived_columns']) }}", ""]
        open(os.path.join(STD, "staging", N.up_stage_name(model, short) + ".sql"), "w",
             encoding="utf-8").write("\n".join(L))
        n_st += 1

print(f"unpivot views      : {n_up}")
print(f"their stage models : {n_st}")
print(f"skipped (reported, not guessed): {sum(skipped.values())}")
for k, c in skipped.most_common():
    print(f"       {c:4d}  {k}")
