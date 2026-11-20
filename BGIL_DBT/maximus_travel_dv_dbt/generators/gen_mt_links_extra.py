# -*- coding: utf-8 -*-
"""gen_mt_links_extra.py -- BUILD-SIDE LINKS the mapper's map does not carry.

The map (04_column_map.json) defines only 4 LNK keys (LNK_CLAIM_PARTY, LNK_PARTY_LOCATION,
LNK_PARTY_ROLE, LNK_POLICY_PARTY). The canonical model has 64 links. This step adds a link for
every canonical link that can be read UNAMBIGUOUSLY off the models gen_mt_stage already wrote:

    a stg2_mt__<view> model qualifies for link L when EACH hub of L has exactly ONE key slot
    (HUB_HKEY, HUB_BK, HUB_NK all present, with or without an __INSTANCE suffix) in that model.

Views with several slots for a hub (e.g. PARTY__INSURED_MEMBER and PARTY__PROPOSER) are skipped:
which party goes with which policy is the mapper's call, and the 4 existing links show the mapper
states it explicitly. Four further pairs that pass the rule but mix entities are in EXCLUDE.
Skipped combinations are listed in build_artifacts/reports/links_extra.json.

Per link L (slug l) it writes, in the same shape as the existing links:
    links/lnkbk_mt_<l>.sql        UNION ALL of hub NK/BK columns from each qualifying stg2_mt__ view
    staging/stg2_mt_lk__<l>.sql   automate_dv.stage(): hub HKEYs + the link HKEY
    links/lnkfeed_mt_<l>.sql      same columns as every other lnkfeed_mt_* view
    links/lnk_<l>.sql             automate_dv.link(), reads lnkfeed_mt_<l>

Hub HKEYs are hashed from the SAME NK column the hub's own stg2 model produced, so a leg always
matches a hub row. The link NK is 'LNK_L|' || BK1 || '|' || BK2 with the hubs in canonical-sheet
order, the convention the 4 existing links use (e.g. POLICY then PARTY).

ORDER: run AFTER gen_mt_vault.py (it wipes links/) and after gen_mt_unpivot.py (it wipes staging/).
It is not in run_all.sh's gate chain; run it last:   python3 gen_mt_links_extra.py
"""
import collections
import glob
import json
import os
import re
import sys

import yaml

HERE = os.path.dirname(os.path.abspath(__file__))
PROJ = os.path.dirname(HERE)
STD = os.path.join(PROJ, "models", "raw_vault", "standard")
STG_DIR = os.path.join(STD, "staging")
LKS_DIR = os.path.join(STD, "link_staging")
LNK_DIR = os.path.join(STD, "links")
REPORT = os.path.join(PROJ, "build_artifacts", "reports", "links_extra.json")

HUBS = ["DISTRIBUTION_CHANNEL", "RISK_OBJECT", "FINANCIAL_TRANSACTION", "PAYMENT_INSTRUMENT",
        "ORG_UNIT", "LOSS_EVENT", "AGREEMENT", "ASSESSMENT", "COVERAGE", "LOCATION", "PARTY",
        "POLICY", "PRODUCT", "PROPOSAL", "QUOTE", "CLAIM", "DOCUMENT", "CASE"]

# Canonical links (Links sheet of GI_DataVault_GI_Canonical_Model.xlsx), hubs in sheet order.
# Only two-hub links are listed; the four the map already defines are excluded.
CANDIDATES = {
    "LNK_PARTY_DOCUMENT": ("Party Document", ["PARTY", "DOCUMENT"]),
    "LNK_PARTY_ORG_UNIT": ("Party Serviced By Org Unit", ["PARTY", "ORG_UNIT"]),
    "LNK_PARTY_CHANNEL": ("Party via Channel", ["PARTY", "DISTRIBUTION_CHANNEL"]),
    "LNK_CHANNEL_ORG_UNIT": ("Channel Managed By Org Unit", ["DISTRIBUTION_CHANNEL", "ORG_UNIT"]),
    "LNK_PRODUCT_COVERAGE": ("Product Coverage", ["PRODUCT", "COVERAGE"]),
    "LNK_QUOTE_PARTY": ("Quote Party", ["QUOTE", "PARTY"]),
    "LNK_QUOTE_PRODUCT": ("Quote Product", ["QUOTE", "PRODUCT"]),
    "LNK_QUOTE_RISK_OBJECT": ("Quote Risk Object", ["QUOTE", "RISK_OBJECT"]),
    "LNK_POLICY_PRODUCT": ("Policy Product", ["POLICY", "PRODUCT"]),
    "LNK_POLICY_COVERAGE": ("Policy Coverage", ["POLICY", "COVERAGE"]),
    "LNK_POLICY_RISK_OBJECT": ("Policy Risk Object", ["POLICY", "RISK_OBJECT"]),
    "LNK_POLICY_COVERAGE_RISK": ("Coverage on Risk Object", ["POLICY", "COVERAGE", "RISK_OBJECT"]),
    "LNK_POLICY_ORG_UNIT": ("Policy Org Unit", ["POLICY", "ORG_UNIT"]),
    "LNK_POLICY_LOCATION": ("Policy Risk Location", ["POLICY", "LOCATION"]),
    "LNK_RISK_OBJECT_LOCATION": ("Risk Object Location", ["RISK_OBJECT", "LOCATION"]),
    "LNK_RISK_OBJECT_PARTY": ("Risk Object Interest", ["RISK_OBJECT", "PARTY"]),
    "LNK_RISK_OBJECT_DOCUMENT": ("Risk Object Document", ["RISK_OBJECT", "DOCUMENT"]),
    "LNK_CLAIM_POLICY": ("Claim Policy", ["CLAIM", "POLICY"]),
    "LNK_CLAIM_DOCUMENT": ("Claim Document", ["CLAIM", "DOCUMENT"]),
    "LNK_CLAIM_LOCATION": ("Claim Location", ["CLAIM", "LOCATION"]),
    "LNK_CLAIM_PAYMENT_INSTRUMENT": ("Claim Payment Instrument", ["CLAIM", "PAYMENT_INSTRUMENT"]),
    "LNK_FINTXN_CLAIM": ("Financial Txn Claim", ["FINANCIAL_TRANSACTION", "CLAIM"]),
    "LNK_FINTXN_PARTY": ("Financial Txn Party", ["FINANCIAL_TRANSACTION", "PARTY"]),
    "LNK_FINTXN_INSTRUMENT": ("Financial Txn Instrument", ["FINANCIAL_TRANSACTION", "PAYMENT_INSTRUMENT"]),
    "LNK_ORG_UNIT_LOCATION": ("Org Unit Location", ["ORG_UNIT", "LOCATION"]),
}


# (link, view) pairs that pass the one-slot rule but pair legs from different entities, found by
# reading each surviving slot name. Recorded in the report under "excluded".
EXCLUDE = {
    ("LNK_POLICY_PRODUCT", "stg2_mt__uwr_pol_prevpol"):
        "only policy slot is PREVIOUS_POLICY; the product belongs to the current policy",
    ("LNK_POLICY_LOCATION", "stg2_mt__clm_clmd_clmrsk_rska_msp_msd_prop_pv"):
        "only location slot is CLAIM_EXPENSE_PARTY_ADDRESS, not a policy risk location",
    ("LNK_CLAIM_LOCATION", "stg2_mt__clm_clmd_clma_msp_msd_prop_pv"):
        "only location slot is DOCUMENT_INWARD_ORIGIN_ADDRESS, not a claim location",
    ("LNK_CHANNEL_ORG_UNIT", "stg2_mt__uwr_qpd"):
        "only org-unit slot is POLICY_ISSUING_BRANCH, not the unit that manages the channel",
}


def read_yaml(path):
    txt = open(path, encoding="utf-8").read()
    return yaml.safe_load(re.search(r"yaml_metadata -%\}\n(.*?)\{%- endset", txt, re.S).group(1))


def slots_of(model_path):
    """{hub: [instance suffix, ...]} for every hub with a full HKEY/BK/NK triple in the model."""
    m = read_yaml(model_path)
    hk, dc = m.get("hashed_columns", {}), m.get("derived_columns", {})
    out = collections.defaultdict(list)
    for k, v in hk.items():
        if not isinstance(v, str):
            continue
        mm = re.match(r"([A-Z_]+?)_HKEY(__.*)?$", k)
        if not mm or mm.group(1) not in HUBS:
            continue
        hub, sfx = mm.group(1), mm.group(2) or ""
        if (hub + "_BK" + sfx) in dc and (hub + "_NK" + sfx) in dc:
            out[hub].append(sfx)
    return out, m


def write(path, text):
    with open(path, "w", encoding="utf-8", newline="\n") as fh:
        fh.write(text)


def main():
    os.makedirs(LKS_DIR, exist_ok=True)
    models = {}
    for f in sorted(glob.glob(os.path.join(STG_DIR, "stg2_mt__*.sql"))):
        slots, meta = slots_of(f)
        models[os.path.basename(f)[:-4]] = (slots, meta)
    report = {"built": {}, "skipped_ambiguous": {}, "excluded": [], "no_source": []}
    for code, (name, hubs) in CANDIDATES.items():
        slug = code[4:].lower()
        ok, amb = [], []
        for t, (slots, meta) in models.items():
            if all(len(slots.get(h, [])) == 1 for h in hubs):
                if (code, t) in EXCLUDE:
                    report["excluded"].append([code, t, EXCLUDE[(code, t)]])
                    continue
                ok.append(t)
            elif all(len(slots.get(h, [])) >= 1 for h in hubs):
                amb.append(t)
        report["skipped_ambiguous"][code] = amb
        if not ok:
            report["no_source"].append(code)
            continue
        report["built"][code] = ok
        pk = "%s_HKEY" % code[4:]
        # ---- lnkbk: union of hub NK/BK columns, one select per qualifying view
        selects = []
        for t in ok:
            slots, meta = models[t]
            cols = []
            for h in hubs:
                s = slots[h][0]
                cols.append("%s_NK%s as %s_NK, %s_BK%s as %s_BK" % (h, s, h, h, s, h))
            where = " and ".join("%s_BK%s is not null" % (h, slots[h][0]) for h in hubs)
            selects.append("    select %s,\n           LOAD_DATETIME, RECORD_SOURCE\n"
                           "    from {{ ref('%s') }}\n    where %s" % (", ".join(cols), t, where))
        bk = ("{{ config(materialized='view', tags=['lnk_extra']) }}\n"
              "-- BUILD-SIDE BUSINESS KEYS for %s (%s): %d feeder(s) over %d hub leg(s).\n"
              "--\n"
              "-- Not in the mapper's map. Each feeder is a stg2_mt__ view in which every hub of this link\n"
              "-- has exactly ONE key slot, so both/all legs come from one source row with no pairing\n"
              "-- guesswork. Views with several slots per hub are deliberately left out. The NK columns\n"
              "-- are the hub stage models' own, so a leg and its hub are byte-identical.\n"
              "-- Written by generators/gen_mt_links_extra.py.\n"
              % (code, name, len(ok), len(hubs))) + "\nunion all\n".join(selects) + "\n"
        write(os.path.join(LNK_DIR, "lnkbk_mt_%s.sql" % slug), bk)
        # ---- stg2: hash the legs and the link key
        lines = ["{{ config(materialized='view', tags=['lnk_extra']) }}",
                 "-- stage() for %s: hub HKEYs (from each hub's own NK) and the link HKEY, over lnkbk_mt_%s." % (code, slug),
                 "-- Link NK = 'LNK_x|' || leg business keys, hubs in canonical-sheet order.",
                 "{%- set yaml_metadata -%}", "source_model: 'lnkbk_mt_%s'" % slug, "hashed_columns:"]
        for h in hubs:
            lines.append("  %s_HKEY: '%s_NK'" % (h, h))
        lines.append("  %s: '%s_NK'" % (pk, code[4:]))
        lines.append("derived_columns:")
        lines.append("  %s_NK: \"'%s|' || %s\"" % (code[4:], code, " || '|' || ".join("%s_BK" % h for h in hubs)))
        lines += ["{%- endset -%}", "{% set metadata_dict = fromyaml(yaml_metadata) %}",
                  "{{ automate_dv.stage(include_source_columns=true,",
                  "                      source_model=metadata_dict['source_model'],",
                  "                      hashed_columns=metadata_dict['hashed_columns'],",
                  "                      derived_columns=metadata_dict['derived_columns']) }}"]
        write(os.path.join(LKS_DIR, "stg2_mt_lk__%s.sql" % slug), "\n".join(lines) + "\n")
        # ---- lnkfeed: same columns as the existing lnkfeed_mt_* views
        sel = ", ".join(["%s as %s" % (pk, pk)] + ["%s_HKEY as %s_HKEY" % (h, h) for h in hubs])
        feed = ("{{ config(materialized='view', tags=['lnk_extra']) }}\n"
                "-- FEED for %s: %d feeder(s) over %d hub leg(s). BUILD-SIDE (not in the mapper's map);\n"
                "-- see lnkbk_mt_%s for the feeders and generators/gen_mt_links_extra.py for the rule.\n"
                "    select %s,\n           LOAD_DATETIME, RECORD_SOURCE\n"
                "    from {{ ref('stg2_mt_lk__%s') }}\n"
                "    where %s is not null\n"
                % (code, len(ok), len(hubs), slug, sel, slug, pk))
        write(os.path.join(LNK_DIR, "lnkfeed_mt_%s.sql" % slug), feed)
        # ---- link
        fk = "\n".join("  - '%s_HKEY'" % h for h in hubs)
        link = ("{{ config(materialized='incremental', tags=['lnk_extra']) }}\n"
                "-- MAXIMUS TRAVEL link() for %s. BUILD-SIDE: not in the mapper's map.\n"
                "-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,\n"
                "-- separate pipelines, one shared vault. This model declares ONLY this project's own\n"
                "-- sources and only the payload it populates -- it does not union the sibling's models.\n"
                "{%%- set yaml_metadata -%%}\n"
                "source_model: 'lnkfeed_mt_%s'\n"
                "src_pk: '%s'\n"
                "src_fk:\n%s\n"
                "src_ldts: 'LOAD_DATETIME'\n"
                "src_source: 'RECORD_SOURCE'\n"
                "{%%- endset -%%}\n"
                "{%% set metadata_dict = fromyaml(yaml_metadata) %%}\n"
                "{{ automate_dv.link(src_pk=metadata_dict['src_pk'],\n"
                "                     src_fk=metadata_dict['src_fk'],\n"
                "                     src_ldts=metadata_dict['src_ldts'],\n"
                "                     src_source=metadata_dict['src_source'],\n"
                "                     source_model=metadata_dict['source_model']) }}\n"
                % (code, slug, pk, fk))
        write(os.path.join(LNK_DIR, "lnk_%s.sql" % slug), link)
    os.makedirs(os.path.dirname(REPORT), exist_ok=True)
    write(REPORT, json.dumps(report, indent=1) + "\n")
    print("gen_mt_links_extra")
    print("  links built     : %d  (%d feeder views)" % (len(report["built"]), sum(len(v) for v in report["built"].values())))
    print("  no unambiguous source: %s" % (", ".join(report["no_source"]) or "none"))
    print("  ambiguous views skipped: %d (see %s)" % (sum(len(v) for v in report["skipped_ambiguous"].values()), REPORT))


if __name__ == "__main__":
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass
    main()
