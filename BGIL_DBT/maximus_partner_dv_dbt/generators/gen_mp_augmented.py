# -*- coding: utf-8 -*-
"""The AUGMENTED track: the 547 columns with no faithful home in data_7.

Unconfirmed and per-column reversible; the standard track is untouched by it.

Conventions are partner_dv_dbt's, measured not assumed: the satellite is named after the HOME
SATELLITE (sat_aug_channel, sat_aug_lnk_role_agent), src_pk is `<HUB>_HKEY`, and the payload column
is the mapper's PROPOSED ATTRIBUTE rendered SQUASHED -- see mp_names.attr_col, which is the one
place partner differs from every other sibling.

Multi-active families get their own unpivot. The 91-column advocate family is six ROLE lines of one
attribute set, not 91 attributes: one column per role would be the wrong grain, exactly as travel's
20 premium heads were.
"""
import collections
import csv
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
AUG = os.path.join(ROOT, "maximus_partner_dv_dbt", "models", "automate_dv", "augmented")
SIBLING = os.path.join(ROOT, "partner_dv_dbt")

for d in ("staging", "satellites"):
    os.makedirs(os.path.join(AUG, d), exist_ok=True)
    for f in glob.glob(os.path.join(AUG, d, "*.sql")):
        os.remove(f)

spec = json.load(open(os.path.join(SRC, "_mp_spec.json"), encoding="utf-8"))
cmap = json.load(open(os.path.join(SRC, "04_column_map.json"), encoding="utf-8"))
MODEL_OF = {t: v["model"] for t, v in spec.items()}

SAT_PK = {}
for f in glob.glob(os.path.join(SIBLING, "models", "automate_dv", "*", "satellites", "*.sql")):
    m = re.search(r"src_pk:\s*'([A-Z0-9_]+)'", open(f, encoding="utf-8").read())
    if m:
        SAT_PK[os.path.basename(f)[:-4].upper()] = m.group(1)
for v in spec.values():
    for s, r in v["sats"].items():
        SAT_PK.setdefault(s.upper(), r["src_pk"])
SIB_AUG = {os.path.basename(f)[:-4].upper(): re.search(r"src_pk:\s*'([A-Z0-9_]+)'",
                                                       open(f, encoding="utf-8").read())
           for f in glob.glob(os.path.join(SIBLING, "models", "automate_dv", "augmented",
                                           "satellites", "*.sql"))}
HUBS = {os.path.basename(f)[4:-4].upper() for f in glob.glob(os.path.join(STD, "hubs", "*.sql"))}

# "Party - Legal Panel Role Line (multi-active; child key = Panel Role Code: DFADVOCATE / ...)"
_NEWSAT = re.compile(r"^(.*?)\s*\((.*)\)\s*$", re.S)
_CK = re.compile(r"child key\s*=\s*([^:)]+)", re.I)
# the permitted values follow the child-key name, slash-separated
_CKVALS = re.compile(r"child key\s*=\s*[^:)]+:\s*([^)]+)", re.I)


def hub_base(pk):
    return re.sub(r"^(HUB|LNK)_", "", re.sub(r"_(HKEY|HK)$", "", pk or ""))


def wide(model):
    p = os.path.join(STD, "staging", N.stage_name(model) + ".sql")
    if not os.path.exists(p):
        return None, {}
    t = open(p, encoding="utf-8").read()
    src = re.search(r"source_model:\s*'([^']+)'", t)
    return (src.group(1) if src else None,
            dict(re.findall(r'^  ([A-Z][A-Z0-9_]*_BK):\s*"(.*)"$', t, re.M)))


def aug_stage_name(model, anchor):
    """ONE WIDE stage per (view, ANCHOR); digest whenever anything is dropped, because truncation
    is not injective."""
    full = f"stg2_aug_mp__{model}__{anchor.lower()}"
    if len(full) <= 70:
        return full
    import hashlib
    keep = max(8, 70 - len("stg2_aug_mp______") - len(anchor) - 6)
    return f"stg2_aug_mp__{model[:keep]}_{hashlib.md5(full.encode()).hexdigest()[:6]}__{anchor.lower()}"


def hashdiff_of(sat):
    return "HASHDIFF_" + re.sub(r"^SAT_", "", sat).upper()


groups = collections.defaultdict(lambda: collections.defaultdict(dict))   # (model, base) -> sat -> {attr: col}
ma_rows = collections.defaultdict(list)      # (model, SAT_AUG_x) -> [{attr, inst, col, base}]
ma_ck = {}
sat_anchor, merged, ruled = {}, [], collections.defaultdict(list)

for x in cmap["columns"]:
    a = x.get("augmentation") or {}
    if not a:
        continue
    tbl, col = x["table_name"], x["column_name"]
    if a.get("redundant_of"):
        # a synonym of a column already routed to this attribute -- coalesced, never a 2nd column
        merged.append((tbl, col))
        continue
    if tbl not in MODEL_OF:
        ruled["source view not in the build"].append((tbl, col))
        continue
    model = MODEL_OF[tbl]
    attr = N.attr_col(a.get("proposed_attribute") or "")
    if not attr:
        ruled["no proposed attribute"].append((tbl, col))
        continue

    home = (a.get("best_home_satellite") or "").split(" (")[0].strip().upper()
    newsat, ck = None, None
    if not home:
        raw = (a.get("new_satellite") or "").strip()
        m = _NEWSAT.match(raw)
        label = (m.group(1) if m else raw).strip()
        if not label:
            ruled["no home and no proposed satellite"].append((tbl, col))
            continue
        # "Party - Legal Panel Role Line" -> SAT_AUG_PARTY_LEGAL_PANEL_ROLE_LINE
        newsat = "SAT_AUG_" + re.sub(r"[^A-Z0-9]+", "_", label.upper()).strip("_")
        cm = _CK.search(m.group(2)) if m else None
        if cm:
            ck = N.attr_col(cm.group(1))
        home = newsat
    sat = newsat or ("SAT_AUG_" + re.sub(r"^SAT_", "", home))

    pk = SAT_PK.get(home) or SAT_PK.get(re.sub(r"^SAT_AUG_", "SAT_", sat))
    base = hub_base(pk) if pk else None
    if not base or base not in HUBS:
        # a proposed satellite whose name starts with a real hub can still be anchored -- this
        # track is explicitly unconfirmed and reversible; the standard track never infers this way
        rest = re.sub(r"^SAT_AUG_", "", sat)
        base = next((h for h in sorted(HUBS, key=len, reverse=True)
                     if rest == h or rest.startswith(h + "_")), None)
    if not base:
        ruled["no resolvable anchor"].append((tbl, col))
        continue

    src, bks = wide(model)
    if not src or f"{base}_BK" not in bks:
        ruled[f"no {base} key on this view"].append((tbl, col))
        continue

    sat_anchor[sat] = base
    if ck:
        # a multi-active family: the ROLE suffix in the column name is the instance
        inst = (a.get("instance") or "").strip()
        if not inst:
            # The role is a SUFFIX of the column name, and the mapper lists the valid roles right
            # after the child-key name: "child key = Panel Role Code: DFADVOCATE / HCADVOCATE /
            # LAWYER / ...". Longest-first so STADVOCATE never loses to a shorter member.
            vm = _CKVALS.search(a.get("new_satellite") or "")
            vals = sorted((v.strip().upper() for v in vm.group(1).split("/") if v.strip()),
                          key=len, reverse=True) if vm else []
            inst = next((v for v in vals if v in col.upper()), None)
        if not inst:
            ruled["multi-active family but no instance on the column"].append((tbl, col))
            continue
        ma_ck[sat] = ck
        ma_rows[(model, sat)].append({"attr": attr, "inst": inst, "col": col, "base": base})
        continue

    if attr in groups[(model, base)][sat]:
        prior = groups[(model, base)][sat][attr]
        groups[(model, base)][sat][attr] = ("coalesce(" + prior + ", " + N.ident(col) + ")"
                                            if not prior.startswith("coalesce(")
                                            else prior[:-1] + ", " + N.ident(col) + ")")
        merged.append((tbl, col))
        continue
    groups[(model, base)][sat][attr] = N.ident(col)

# ---- multi-active families: one row per instance -------------------------------------------
payload_of = collections.defaultdict(set)
MA_PAY = collections.defaultdict(set)
for (model, sat), rows in ma_rows.items():
    MA_PAY[sat] |= {r["attr"] for r in rows}
ma_sats, n_ma = {}, 0
for (model, sat), rows in sorted(ma_rows.items()):
    base, ck = rows[0]["base"], ma_ck[sat]
    src, bks = wide(model)
    attrs = sorted(MA_PAY[sat])
    byinst = collections.defaultdict(dict)
    for r in rows:
        byinst[r["inst"]][r["attr"]] = r["col"]
    name = N._fit(f"unpivot_aug_mp__{model}__{re.sub(r'^SAT_AUG_', '', sat).lower()}", 70)
    branches = []
    for inst in sorted(byinst):
        sel = [f"        {bks[f'{base}_BK']} as parent_bk",
               f"        {N.sql_str(inst)} as {ck.lower()}"]
        sel += [f"        {N.ident(byinst[inst][a])} as {a.lower()}" if a in byinst[inst]
                else f"        cast(null as varchar) as {a.lower()}" for a in attrs]
        sel.append(f"        {N.sql_str(model)} as record_source")
        guard = " or ".join(f"nullif(trim(to_varchar({N.ident(c)})), '') is not null"
                            for c in byinst[inst].values())
        branches.append("    select\n" + ",\n".join(sel) +
                        f"\n    from {{{{ ref('{src}') }}}}\n    where {guard}")
    open(os.path.join(AUG, "staging", name + ".sql"), "w", encoding="utf-8").write(
        "{{ config(materialized='view') }}\n\n"
        f"-- MAXIMUS PARTNER AUGMENTED (unconfirmed) UNPIVOT for {sat} from '{model}'.\n"
        f"-- {len(branches)} row(s), ONE PER INSTANCE of {ck}. Each source column is the SAME\n"
        f"-- attribute for a DIFFERENT {ck.lower()}; one column per source column would be the\n"
        "-- wrong grain.\n\n" + "\n    union all\n".join(branches) + "\n")
    stg = N._fit(f"stg2_aug_mp_up__{model}__{re.sub(r'^SAT_AUG_', '', sat).lower()}", 70)
    L = ["{{ config(materialized='view') }}", "",
         f"-- stage() over the {sat} augmented unpivot for '{model}'.", "",
         "{%- set yaml_metadata -%}", f"source_model: '{name}'", "hashed_columns:",
         f"  {base}_HKEY: '{base}_NK'", f"  {hashdiff_of(sat)}:", "    is_hashdiff: true",
         "    columns:"]
    L += [f"      - '{a}'" for a in attrs]
    L += ["derived_columns:", f'  {base}_BK: "parent_bk"',
          f'  {base}_NK: "\'HUB_{base}|\' || (parent_bk)"',
          "  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'", "{%- endset -%}", "",
          "{% set metadata_dict = fromyaml(yaml_metadata) %}", "",
          "{{ automate_dv.stage(include_source_columns=true,",
          "                     source_model=metadata_dict['source_model'],",
          "                     hashed_columns=metadata_dict['hashed_columns'],",
          "                     derived_columns=metadata_dict['derived_columns']) }}", ""]
    open(os.path.join(AUG, "staging", stg + ".sql"), "w", encoding="utf-8").write("\n".join(L))
    e = ma_sats.setdefault(sat, {"base": base, "ck": ck, "srcs": [], "attrs": set()})
    e["srcs"].append(stg)
    e["attrs"] |= set(MA_PAY[sat])
    n_ma += 2
for sat, e in ma_sats.items():
    payload_of[sat] |= e["attrs"]
    sat_anchor[sat] = e["base"]

# ---- wide augmented stage, one per (view, anchor) -------------------------------------------
for (model, base), sats in groups.items():
    for sat, cols in sats.items():
        payload_of[sat] |= set(cols)

n_stage = 0
for (model, base), sats in sorted(groups.items()):
    src, bks = wide(model)
    full = sorted(set().union(*(payload_of[s] for s in sats)))
    here = {}
    for cols in sats.values():
        here.update(cols)
    name = aug_stage_name(model, base)
    L = ["{{ config(materialized='view') }}", "",
         f"-- MAXIMUS PARTNER AUGMENTED (unconfirmed) WIDE stage() for HUB_{base}, view '{model}'.",
         f"-- Serves {len(sats)} augmented satellite(s), one HASHDIFF each, from {len(here)}",
         "-- column(s) with no faithful home in data_7. The KEY is the standard track's own",
         f"-- expression for HUB_{base} on this view; the ATTRIBUTE GROUPING is the mapper's",
         "-- proposal and is NOT canonical.", "",
         "{%- set yaml_metadata -%}", f"source_model: '{src}'", "hashed_columns:",
         f"  {base}_HKEY: '{base}_NK'"]
    for s in sorted(sats):
        L += [f"  {hashdiff_of(s)}:", "    is_hashdiff: true", "    columns:"]
        L += [f"      - '{p}'" for p in sorted(payload_of[s])]
    L += ["derived_columns:", f'  {base}_BK: "{bks[f"{base}_BK"]}"',
          f'  {base}_NK: "\'HUB_{base}|\' || ({bks[f"{base}_BK"]})"']
    L += [f'  {p}: "{here[p]}"' if p in here else f'  {p}: "cast(null as varchar)"' for p in full]
    L += ["  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'", f"  RECORD_SOURCE: '!{model}'",
          "{%- endset -%}", "", "{% set metadata_dict = fromyaml(yaml_metadata) %}", "",
          "{{ automate_dv.stage(include_source_columns=false,",
          "                     source_model=metadata_dict['source_model'],",
          "                     hashed_columns=metadata_dict['hashed_columns'],",
          "                     derived_columns=metadata_dict['derived_columns']) }}", ""]
    open(os.path.join(AUG, "staging", name + ".sql"), "w", encoding="utf-8").write("\n".join(L))
    n_stage += 1

# ---- the satellites --------------------------------------------------------------------------
n_sat = shared = 0
for sat in sorted(payload_of):
    base = sat_anchor[sat]
    pk = f"{base}_HKEY"
    sib = SIB_AUG.get(sat)
    if sib:
        shared += 1
        if sib:
            pk = sib.group(1)
    if sat in ma_sats:
        srcs = sorted(set(ma_sats[sat]["srcs"]))
    else:
        srcs = sorted(aug_stage_name(m, b) for (m, b), ss in groups.items() if sat in ss)
    if not srcs:
        continue
    macro = "ma_sat" if sat in ma_sats else "sat"
    cdkblock = f"src_cdk:\n  - '{ma_sats[sat]['ck']}'\n" if sat in ma_sats else ""
    cdkarg = ("src_cdk=metadata_dict['src_cdk'],\n                   "
              if sat in ma_sats else "")
    note = (f"-- Writes the SAME physical table as partner_dv_dbt's {sat.lower()}.\n" if sib
            else f"-- partner_dv_dbt does not build {sat.lower()}; Maximus-only augmented table.\n")
    sql = f"""{{{{ config(materialized='incremental') }}}}

-- MAXIMUS PARTNER AUGMENTED (unconfirmed) {macro}() for {sat}, at HUB_{base} grain.
{note}-- Payload columns are the mapper's PROPOSED ATTRIBUTE names in partner_dv_dbt's own rendering
-- (squashed), not raw Maximus column names -- a shared table must not gain a second column for a
-- fact that already has one. NOT part of the canonical model.

{{%- set yaml_metadata -%}}
source_model:
{chr(10).join(f"  - '{s}'" for s in srcs)}
src_pk: '{pk}'
{cdkblock}src_payload:
{chr(10).join(f"  - '{p}'" for p in sorted(payload_of[sat]))}
src_hashdiff: '{hashdiff_of(sat)}'
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
    open(os.path.join(AUG, "satellites", sat.lower() + ".sql"), "w",
         encoding="utf-8").write(sql)
    n_sat += 1

routed = sum(len(c) for sats in groups.values() for c in sats.values())
ma_cols = sum(len(v) for v in ma_rows.values())
print(f"aug stage models   : {n_stage + n_ma}  ({n_ma} of them multi-active unpivot + stage)")
print(f"SAT_AUG_* sats     : {n_sat}   ({shared} already in partner_dv_dbt, "
      f"{len(ma_sats)} multi-active)")
print(f"columns routed     : {routed + ma_cols}   ({ma_cols} via a multi-active unpivot)")
print(f"  merged into an existing attribute (redundant / synonym): {len(merged)}")
for k in sorted(ruled):
    print(f"  NOT routed - {k:52s}: {len(ruled[k])}")
_tot = routed + ma_cols + len(merged) + sum(len(v) for v in ruled.values())
_all = sum(1 for x in cmap["columns"] if x.get("augmentation"))
assert _tot == _all, f"augmentation columns unaccounted for: {_tot} of {_all}"
print(f"  ACCOUNTED FOR      : {_tot} of {_all}")

# The report goes to a file this script never READS -- asserted over the whole input set, because
# a comment saying so went stale on travel and destroyed a mapper's filled sheet.
_INPUTS = {os.path.abspath(os.path.join(SRC, n)) for n in
           ("04_column_map.json", "modeler_feedback.json", "PARTNER_PREEMPTIVE_ANSWERS.md")}
out = os.path.join(SRC, "MAXIMUS_PARTNER_AUG_UNROUTED.csv")
assert os.path.abspath(out) not in _INPUTS
with open(out, "w", encoding="utf-8-sig", newline="") as fh:
    w = csv.writer(fh)
    w.writerow(["reason", "view_or_model", "column", "ANCHOR", "ROUTING", "NOTE"])
    for k in sorted(ruled):
        for tbl, col in sorted(ruled[k]):
            w.writerow([k, tbl, col, "", "", ""])
print(f"unrouted written   : {os.path.basename(out)}")
