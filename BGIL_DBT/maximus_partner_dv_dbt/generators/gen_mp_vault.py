# -*- coding: utf-8 -*-
"""Layer 3: hubfeed views, hubs, links, satellites.

Writes the SAME physical tables as partner_dv_dbt from a different source system. Two things that
were real bugs on the earlier builds and are designed out here:

  * a hub's src_nk column name must match what partner_dv_dbt already writes (PARENT_BK). A wide
    stage model serves many hubs so it cannot emit one PARENT_BK -- a thin per-hub FEED view does
    the rename, otherwise both projects populate different columns of one table.
  * a source only counts if it really EMITS the required columns, and a stage() with
    include_source_columns=true ALSO passes its source model's columns through. Reading the YAML
    alone made the unpivots' child keys invisible and silently built no satellite for 44 of them
    on travel -- with every other check green, because a model that is never written has nothing
    wrong with it.
"""
import collections
import glob
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
SIBLING = os.path.join(ROOT, "partner_dv_dbt")
spec = json.load(open(os.path.join(SRC, "_mp_spec.json"), encoding="utf-8"))

for d in ("hubs", "links", "satellites", "hubfeed"):
    for f in glob.glob(os.path.join(STD, d, "*.sql")):
        os.remove(f)


def _yaml_cols(t):
    return set(re.findall(r"""^\s{2}([A-Z][A-Z0-9_]+):\s*(?:["']|$)""", t, re.M))


def _view_cols(t):
    return {a.upper() for a in re.findall(r"\bas\s+([A-Za-z_][A-Za-z0-9_]*)\s*(?=,|$)", t, re.M)}


UNPIVOT = {os.path.basename(f)[:-4]: _view_cols(open(f, encoding="utf-8").read())
           for f in glob.glob(os.path.join(STD, "unpivot", "*.sql"))}
EMITS = {}
for f in glob.glob(os.path.join(STD, "staging", "*.sql")):
    t = open(f, encoding="utf-8").read()
    cols = _yaml_cols(t)
    if "include_source_columns=true" in t:
        m = re.search(r"source_model:\s*'([^']+)'", t)
        if m and m.group(1) in UNPIVOT:
            cols |= UNPIVOT[m.group(1)]
    EMITS[os.path.basename(f)[:-4]] = cols

# what partner_dv_dbt names its hub key columns -- we write its tables
SIBH = {}
for f in glob.glob(os.path.join(SIBLING, "models", "automate_dv", "*", "hubs", "*.sql")):
    t = open(f, encoding="utf-8").read()
    p = re.search(r"src_pk:\s*'([A-Z0-9_]+)'", t)
    nk = re.search(r"src_nk:\s*'([A-Z0-9_]+)'", t)
    if p and nk:
        SIBH[os.path.basename(f)[:-4]] = (p.group(1), nk.group(1))

HDR = """{{{{ config(materialized='incremental') }}}}

-- MAXIMUS PARTNER {kind} for {obj}.
-- Writes the SAME physical table as partner_dv_dbt's model of the same name: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY Maximus's sources and only the
-- payload Maximus populates, which is what removes any need to back-patch the other project.
"""

anchors = collections.defaultdict(set)
for tbl, v in spec.items():
    for a in list(v["keys"]) + [r["anchor"] for r in v["sats"].values()]:
        anchors[a].add(tbl)

n_hub = n_lnk = n_sat = 0
for anchor in sorted(anchors):
    base = re.sub(r"^(HUB|LNK)_", "", anchor)
    srcs = sorted(m for m, c in EMITS.items() if f"{base}_HKEY" in c and f"{base}_BK" in c)
    if not srcs:
        continue
    name = ("hub_" if anchor.startswith("HUB_") else "") + base.lower()
    opus_pk, opus_nk = SIBH.get(name, (f"{base}_HKEY", "PARENT_BK"))
    feed = f"hubfeed_{base.lower()}"
    parts = "\n    union all\n".join(
        f"    select {base}_HKEY as {opus_pk}, {base}_BK as {opus_nk},\n"
        f"           LOAD_DATETIME, RECORD_SOURCE\n    from {{{{ ref('{s}') }}}}" for s in srcs)
    open(os.path.join(STD, "hubfeed", feed + ".sql"), "w", encoding="utf-8").write(
        "{{ config(materialized='view') }}\n\n"
        f"-- Feed for {anchor}: renames Maximus's {base}_BK / {base}_HKEY to the names\n"
        f"-- partner_dv_dbt already writes ({opus_nk} / {opus_pk}), so both projects populate ONE\n"
        "-- set of columns in the shared table instead of two.\n\n" + parts + "\n")

    if anchor.startswith("LNK_"):
        legs = K.LINK_LEGS.get(anchor)
        if not legs:
            continue
        lpk = base + "_HKEY"
        leg_cols = [re.sub(r"^(HUB|LNK)_", "", l) + "_HKEY" for l in legs]
        # A same-hub link takes its leg names from the rule, which spells each one out -- one
        # column cannot serve both legs, and aliasing the second onto the first would file every
        # relationship as self-referential.
        rule = next((vv["keys"][anchor].get("rule") for vv in spec.values()
                     if anchor in vv["keys"] and vv["keys"][anchor].get("rule")), "")
        named = K.link_legs_from_rule(rule)
        if len(named) >= 2:
            leg_cols = [c + "_HKEY" for c, _t, _x in named]
        if len(set(leg_cols)) != len(leg_cols):
            print(f"  !! {anchor}: repeated leg {leg_cols} -- reported, not guessed")
            continue
        lsrcs = sorted(m for m, c in EMITS.items()
                       if f"{base}_HKEY" in c and all(l in c for l in leg_cols))
        if not lsrcs:
            print(f"  !! {anchor}: no stage model emits all legs {leg_cols} -- SKIPPED")
            continue
        lfeed = f"hubfeed_{base.lower()}_lnk"
        sel = ", ".join(leg_cols)
        lparts = "\n    union all\n".join(
            f"    select {base}_HKEY as {lpk}, {sel},\n"
            f"           LOAD_DATETIME, RECORD_SOURCE\n    from {{{{ ref('{s}') }}}}"
            for s in lsrcs)
        open(os.path.join(STD, "hubfeed", lfeed + ".sql"), "w", encoding="utf-8").write(
            "{{ config(materialized='view') }}\n\n"
            f"-- Feed for {anchor}: renames Maximus's {base}_HKEY to the model's key name.\n\n"
            + lparts + "\n")
        sql = HDR.format(kind="link()", obj=anchor) + f"""
{{%- set yaml_metadata -%}}
source_model:
  - '{lfeed}'
src_pk: '{lpk}'
src_fk:
{chr(10).join(f"  - '{l}'" for l in leg_cols)}
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{{%- endset -%}}

{{% set metadata_dict = fromyaml(yaml_metadata) %}}

{{{{ automate_dv.link(src_pk=metadata_dict['src_pk'],
                     src_fk=metadata_dict['src_fk'],
                     src_ldts=metadata_dict['src_ldts'],
                     src_source=metadata_dict['src_source'],
                     source_model=metadata_dict['source_model']) }}}}
"""
        open(os.path.join(STD, "links", anchor.lower() + ".sql"), "w",
             encoding="utf-8").write(sql)
        n_lnk += 1
        continue

    sql = HDR.format(kind="hub()", obj=anchor) + f"""
{{%- set yaml_metadata -%}}
source_model:
  - '{feed}'
src_pk: '{opus_pk}'
src_nk: '{opus_nk}'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{{%- endset -%}}

{{% set metadata_dict = fromyaml(yaml_metadata) %}}

{{{{ automate_dv.hub(src_pk=metadata_dict['src_pk'],
                    src_nk=metadata_dict['src_nk'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}}}
"""
    open(os.path.join(STD, "hubs", name + ".sql"), "w", encoding="utf-8").write(sql)
    n_hub += 1

# ---- satellites --------------------------------------------------------------------------
sats = collections.defaultdict(lambda: {"srcs": set(), "pay": set(), "pk": None,
                                        "ma": False, "cdk": []})
for tbl, v in spec.items():
    m = v["model"]
    for sat, r in v["sats"].items():
        e = sats[sat]
        e["pk"], e["ma"], e["cdk"] = r["src_pk"], r["ma"], r["cdk"]
        e["pay"] |= {N.attr_col(a) for a in r["payload"]}
        short = re.sub(r"^SAT_", "", sat).lower()
        up = N.up_stage_name(m, short)
        built = os.path.exists(os.path.join(STD, "staging", up + ".sql"))
        if r["ma"] and r["cdk"]:
            # a multi-active satellite can ONLY be fed by its unpivot -- the sole layer that
            # defines the child key
            if built:
                e["srcs"].add(up)
        else:
            e["srcs"].add(up if built else N.stage_name(m))

for sat, e in sorted(sats.items()):
    hd = "HASHDIFF_" + sat.replace("SAT_", "", 1).upper()
    need = {e["pk"], hd} | set(e["cdk"] if (e["ma"] and e["cdk"]) else [])
    srcs = sorted(s for s in e["srcs"] if not (need - EMITS.get(s, set())))
    if not srcs:
        continue
    macro = "ma_sat" if (e["ma"] and e["cdk"]) else "sat"
    cdkblock = ("src_cdk:\n" + "\n".join(f"  - '{c}'" for c in e["cdk"]) + "\n"
                if macro == "ma_sat" else "")
    cdkarg = ("src_cdk=metadata_dict['src_cdk'],\n                       "
              if macro == "ma_sat" else "")
    pay = "\n".join(f"  - '{p}'" for p in sorted(e["pay"]))
    sql = HDR.format(kind=f"{macro}()", obj=sat) + f"""
{{%- set yaml_metadata -%}}
source_model:
{chr(10).join(f"  - '{s}'" for s in srcs)}
src_pk: '{e['pk']}'
{cdkblock}src_payload:
{pay}
src_hashdiff: '{hd}'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{{%- endset -%}}

{{% set metadata_dict = fromyaml(yaml_metadata) %}}

{{{{ automate_dv.{macro}(src_pk=metadata_dict['src_pk'],
                       {cdkarg}src_payload=metadata_dict['src_payload'],
                       src_hashdiff=metadata_dict['src_hashdiff'],
                       src_ldts=metadata_dict['src_ldts'],
                       src_source=metadata_dict['src_source'],
                       source_model=metadata_dict['source_model']) }}}}
"""
    open(os.path.join(STD, "satellites", sat.lower() + ".sql"), "w",
         encoding="utf-8").write(sql)
    n_sat += 1

print(f"hubfeed views : {len(glob.glob(os.path.join(STD, 'hubfeed', '*.sql')))}")
print(f"hubs          : {n_hub}")
print(f"links         : {n_lnk}")
print(f"satellites    : {n_sat}   of {len(sats)} targeted")
