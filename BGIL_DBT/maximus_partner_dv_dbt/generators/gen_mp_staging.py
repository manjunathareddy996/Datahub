# -*- coding: utf-8 -*-
"""Layer 1: one stg_maximus__<view> cast per source view, plus _sources.yml."""
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mp_names as N
import mp_keyrules as K

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
SRC = os.path.join(ROOT, "maximum_partner")
OUT = os.path.join(ROOT, "maximus_partner_dv_dbt", "models", "staging", "maximus")
spec = json.load(open(os.path.join(SRC, "_mp_spec.json"), encoding="utf-8"))

os.makedirs(OUT, exist_ok=True)
for f in os.listdir(OUT):
    if f.endswith(".sql"):
        os.remove(os.path.join(OUT, f))

NUM = re.compile(r"(AMOUNT|_AMT|PERCENT|_PCT|RATE|COUNT|NUMBER_OF|QTY|QUANTITY|BALANCE|LIMIT)$")

src_yml = ["version: 2", "", "sources:", "  - name: maximus_partner",
           "    database: \"{{ var('maximus_partner_raw_database') }}\"",
           "    schema: \"{{ var('maximus_partner_raw_schema') }}\"", "    tables:"]

n = 0
for tbl, v in sorted(spec.items()):
    src_yml.append(f"      - name: {tbl}")
    lines = ["{{ config(materialized='view') }}", "",
             f"-- MAXIMUS PARTNER layer-1 cast for {tbl}.", "",
             "with source as (", "", "    select"]
    body = []
    for c in sorted(v["all_cols"]):
        # every column is cast to text unless its NAME says it is a measure -- the same
        # conservative rule the other Maximus builds use
        if NUM.search(c.upper()):
            body.append(f'    try_to_number(to_varchar("{c}")) as {N.ident(c)},')
        else:
            body.append(f"""    nullif(trim(to_varchar("{c}")), '') as {N.ident(c)},""")
    # the shred spine is on the view but never in the map, so it is added explicitly
    for s in sorted(K.SPINE_COLS):
        body.append(f"""    nullif(trim(to_varchar("{s.upper()}")), '') as {s},""")
    body[-1] = body[-1].rstrip(",")
    lines += body
    lines += [f"    from {{{{ source('maximus_partner', '{tbl}') }}}}", "", ")", "",
              "select * from source", ""]
    open(os.path.join(OUT, f"stg_maximus__{v['model']}.sql"), "w",
         encoding="utf-8").write("\n".join(lines))
    n += 1

open(os.path.join(OUT, "_sources.yml"), "w", encoding="utf-8").write("\n".join(src_yml) + "\n")
print(f"source views      : {len(spec)}")
print(f"layer-1 casts     : {n}")
print(f"longest model name: {max(len(v['model']) for v in spec.values())}")
