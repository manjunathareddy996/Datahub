# -*- coding: utf-8 -*-
"""gen_partner_links_extra.py -- BUILD-SIDE LINKS for opus_partner_dv_dbt and maximus_partner_dv_dbt.

Adds the canonical links (GI_DataVault_GI_Canonical_Model.xlsx, sheet "Links") that can be read off
the models the partner builds already have, using the same two rules as the travel builds:

  opus_partner     (opus_travel rule)   a link is built from every source table that feeds a hub for EACH
                                         leg (stg2_hub_<table>__<hub>.sql). One stg2_link_<table>__<slug>
                                         model per (link, table); lnk_<slug> unions them.
  maximus_partner  (maximus_travel rule) a link is built from every stg2_mp__ view that has exactly ONE key
                                         slot (HKEY/BK/NK) for each hub of the link.
                                         lnkbk_mp_ -> stg2_mp_lk__ -> lnkfeed_mp_ -> lnk_.

Every leg is hashed from the SAME expression the hub's own stage model uses, so a leg always matches a
hub row. Link NK = 'LNK_X|' || leg BKs, hubs in canonical-sheet order.

Party leg exceptions (opus): HUB_PARTY is keyed on part_id only, so the party leg is part_id, not the
table's own party column. bjaz_intermediary/bjaz_clm_supp_extn -> partner_id, clm_interested_parties -> part_id
(same as the existing stg2_link_* models). KYC tables resolve part_id through stage_kyc__<table>.

NOT in the mapper's map. Pending mapper confirmation. Not compiled or run.
Run AFTER gen_mp_vault.py (it wipes links/):   python3 gen_partner_links_extra.py
Report: gen_partner_links_extra_report.json (next to this file).
"""
import collections
import glob
import json
import os
import re
import sys

import yaml

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))          # .../BGIL_DBT
OP = os.path.join(ROOT, "opus_partner_dv_dbt", "models", "raw_vault", "standard")
MP = os.path.join(ROOT, "maximus_partner_dv_dbt", "models", "raw_vault", "standard")
REPORT = os.path.join(HERE, "gen_partner_links_extra_report.json")

# link code -> (name, hubs in canonical-sheet order)
LINKS = {
    "LNK_AGREEMENT_PARTY": ("Agreement Party", ["AGREEMENT", "PARTY"]),
    "LNK_AGREEMENT_CHANNEL": ("Agreement Channel", ["AGREEMENT", "DISTRIBUTION_CHANNEL"]),
    "LNK_PARTY_DOCUMENT": ("Party Document", ["PARTY", "DOCUMENT"]),
    "LNK_PARTY_ORG_UNIT": ("Party Serviced By Org Unit", ["PARTY", "ORG_UNIT"]),
    "LNK_PARTY_CHANNEL": ("Party via Channel", ["PARTY", "DISTRIBUTION_CHANNEL"]),
    "LNK_PARTY_PAYMENT_INSTRUMENT": ("Party Payment Instrument", ["PARTY", "PAYMENT_INSTRUMENT"]),
    "LNK_CHANNEL_ORG_UNIT": ("Channel Managed By Org Unit", ["DISTRIBUTION_CHANNEL", "ORG_UNIT"]),
    "LNK_POLICY_PARTY": ("Policy Party", ["POLICY", "PARTY"]),
    "LNK_POLICY_PRODUCT": ("Policy Product", ["POLICY", "PRODUCT"]),
    "LNK_POLICY_CHANNEL": ("Policy Channel", ["POLICY", "DISTRIBUTION_CHANNEL"]),
    "LNK_POLICY_ORG_UNIT": ("Policy Org Unit", ["POLICY", "ORG_UNIT"]),
    "LNK_POLICY_LOCATION": ("Policy Risk Location", ["POLICY", "LOCATION"]),
    "LNK_POLICY_DOCUMENT": ("Policy Document", ["POLICY", "DOCUMENT"]),
    "LNK_RISK_OBJECT_PARTY": ("Risk Object Interest", ["RISK_OBJECT", "PARTY"]),
    "LNK_CLAIM_RISK_OBJECT": ("Claim Risk Object", ["CLAIM", "RISK_OBJECT"]),
    "LNK_ORG_UNIT_LOCATION": ("Org Unit Location", ["ORG_UNIT", "LOCATION"]),
}
# links to build per project (the new ones only; existing partner links are left alone)
OPUS_LINKS = ["LNK_AGREEMENT_CHANNEL", "LNK_AGREEMENT_PARTY", "LNK_CLAIM_RISK_OBJECT", "LNK_PARTY_CHANNEL",
              "LNK_PARTY_DOCUMENT", "LNK_PARTY_ORG_UNIT", "LNK_POLICY_DOCUMENT", "LNK_POLICY_LOCATION",
              "LNK_POLICY_ORG_UNIT", "LNK_RISK_OBJECT_PARTY"]
MAX_LINKS = ["LNK_CHANNEL_ORG_UNIT", "LNK_ORG_UNIT_LOCATION", "LNK_PARTY_CHANNEL", "LNK_PARTY_ORG_UNIT",
             "LNK_PARTY_PAYMENT_INSTRUMENT", "LNK_POLICY_CHANNEL", "LNK_POLICY_LOCATION", "LNK_POLICY_ORG_UNIT",
             "LNK_POLICY_PARTY", "LNK_POLICY_PRODUCT"]

# opus: party leg column per source table (part_id space = HUB_PARTY key)
PARTY_COL = {"bjaz_intermediary": "partner_id", "bjaz_clm_supp_extn": "partner_id",
             "clm_interested_parties": "part_id"}
KYC_TABLES = {"bjaz_t_ckyc_otp", "bjaz_t_ckyc_search", "bjaz_t_ekyc", "bjaz_t_kyc_auth", "bjaz_t_kyc_details",
              "bjaz_t_kyc_incoming", "bjaz_t_kyc_name_match", "bjaz_t_kyc_ocr", "bjaz_t_kyc_poa_document",
              "bjaz_t_kyc_poi_document"}

# Pairs the one-rule check accepts but the mapper should confirm (reported, still built).
DOUBTFUL = {
    "LNK_POLICY_DOCUMENT": "policy key exists only on rows whose field_type is a policy; the document key is then "
                           "built from the same field_value, so the pair may be a value linked to itself",
    "LNK_PARTY_DOCUMENT": "KYC document keys (field_type:field_value or docs_type:docs_number); confirm the party is "
                          "the document owner",
    "LNK_AGREEMENT_CHANNEL": "both legs are bjaz_intermediary.intermediary_id",
    "LNK_POLICY_LOCATION": "location leg is ocp_interested_parties.mailing_address_id, not a policy risk location",
}
DOUBTFUL_MAX = "all legs of this link come from pd_prop_sp_pv: PARTY_BK is bagic_employee_code and POLICY_BK is pa_policy, so these are employee-based keys"


def read_yaml(path):
    txt = open(path, encoding="utf-8").read()
    return yaml.safe_load(re.search(r"yaml_metadata -%\}\n(.*?)\{%- endset", txt, re.S).group(1))


def write(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8", newline="\n") as fh:
        fh.write(text)


def q(s):
    return json.dumps(s)          # YAML double-quoted scalar


# --------------------------------------------------------------------------------------- opus_partner
def opus():
    stg = os.path.join(OP, "staging")
    hubs = collections.defaultdict(dict)       # table -> hub -> parsed yaml
    for f in glob.glob(os.path.join(stg, "stg2_hub_*.sql")):
        if "enabled=false" in open(f, encoding="utf-8").read():
            continue
        n = os.path.basename(f)[9:-4]
        t, rest = n.split("__", 1)
        parts = rest.split("__")
        if len(parts) > 1:
            continue                           # instance branches (e.g. kyc_subject) are not link sources
        hubs[t][parts[0].upper()] = read_yaml(f)
    report = {"built": {}, "doubtful": {}, "helpers": []}
    # KYC helpers for the two document tables (res_kyc has the resolvers, stage_kyc has no model for them)
    for t, key in (("bjaz_t_kyc_poa_document", "poa_doc_id"), ("bjaz_t_kyc_poi_document", "poi_doc_id")):
        write(os.path.join(stg, "stage_kyc__%s.sql" % t),
              "{{ config(materialized='view') }}\n"
              "-- KYC STAGE: %s + resolved part_id (%s -> BJAZ_T_KYC_DETAILS partner row).\n"
              "-- Same shape as the other stage_kyc__ models; needed so KYC document links can carry the party leg.\n"
              "-- Written by generators/gen_partner_links_extra.py.\n"
              "with src as (select * from {{ ref('stg_partner__%s') }})\n"
              ", res as (select * from {{ ref('res_kyc__part_by_%s') }})\n"
              "select\n    src.*,\n    res.part_id,\n    res.part_id_n,\n    (res.part_id is not null) as hub_party_emit\n"
              "from src\nleft join res on src.%s = res.%s\n"
              % (t.upper(), key.upper(), t, key, key, key))
        report["helpers"].append("stage_kyc__" + t)
    for code in OPUS_LINKS:
        name, legs = LINKS[code]
        slug = code[4:].lower()
        pk = code[4:] + "_HKEY"
        srcs = []
        for t in sorted(hubs):
            h = hubs[t]
            non_party = [x for x in legs if x != "PARTY"]
            if not all(x in h for x in non_party):
                continue
            if "PARTY" in legs and not (t in PARTY_COL or t in KYC_TABLES):
                continue
            if "PARTY" not in legs and not all(x in h for x in legs):
                continue
            ref_src = {h[x]["source_model"] for x in non_party}
            if len(ref_src) != 1:
                raise SystemExit("%s/%s: legs have different source models %s" % (code, t, ref_src))
            base = ref_src.pop()
            first = h[non_party[0]]
            hk, derived = {}, {}
            for x in legs:
                if x == "PARTY":
                    col = PARTY_COL.get(t, "part_id")
                    bk = col
                    nk = "'HUB_PARTY|' || %s" % col
                else:
                    d = h[x]["derived_columns"]
                    bk, nk = d["PARENT_BK"], d["PARENT_NK"]
                hk["%s_HKEY" % x] = "%s_HKEY_NK" % x
                derived["%s_HKEY_NK" % x] = nk
                derived["_BK_%s" % x] = bk
            derived["%s_NK" % code[4:]] = "'%s|' || " % code + " || '|' || ".join("(%s)" % derived["_BK_%s" % x] for x in legs)
            hk[pk] = "%s_NK" % code[4:]
            for x in legs:
                del derived["_BK_%s" % x]
            source = base
            if "PARTY" in legs and t in KYC_TABLES:
                source = "stage_kyc__" + t
            derived["LOAD_DATETIME"] = first["derived_columns"]["LOAD_DATETIME"]
            derived["RECORD_SOURCE"] = first["derived_columns"]["RECORD_SOURCE"]
            model = "stg2_link_%s__%s" % (t, slug)
            lines = ["{{ config(materialized='view') }}",
                     "-- PARTNER STANDARD-MODEL per-table stage() for %s (%s), table '%s'." % (code, name, t.upper()),
                     "-- BUILD-SIDE: not in the mapper's map. Each non-party leg reuses the exact key expression of its",
                     "-- hub's own stage model (stg2_hub_%s__<hub>), so a leg always matches a hub row." % t,
                     "-- Party leg = part_id space (HUB_PARTY is keyed on part_id). Written by generators/gen_partner_links_extra.py.",
                     "{%- set yaml_metadata -%}", "source_model: %s" % q(source), "hashed_columns:"]
            lines += ["  %s: %s" % (k, q(v)) for k, v in hk.items()]
            lines.append("derived_columns:")
            lines += ["  %s: %s" % (k, q(v)) for k, v in derived.items()]
            lines += ["{%- endset -%}", "{% set metadata_dict = fromyaml(yaml_metadata) %}",
                      "{{ automate_dv.stage(include_source_columns=false,",
                      "                      source_model=metadata_dict['source_model'],",
                      "                      hashed_columns=metadata_dict['hashed_columns'],",
                      "                      derived_columns=metadata_dict['derived_columns']) }}"]
            write(os.path.join(stg, model + ".sql"), "\n".join(lines) + "\n")
            srcs.append(model)
        if not srcs:
            report.setdefault("no_source", []).append(code)
            continue
        fk = sorted("%s_HKEY" % x for x in legs)
        text = ("{{ config(materialized='incremental') }}\n"
                "-- PARTNER STANDARD-MODEL link() for %s (%s), %d contributing table(s). BUILD-SIDE: not in the mapper's map.\n"
                "-- Writes the SAME physical table as the other builds' model of the same name.\n"
                "{%%- set yaml_metadata -%%}\nsource_model:\n%s\nsrc_pk: '%s'\nsrc_fk:\n%s\n"
                "src_ldts: 'LOAD_DATETIME'\nsrc_source: 'RECORD_SOURCE'\n{%%- endset -%%}\n"
                "{%% set metadata_dict = fromyaml(yaml_metadata) %%}\n"
                "{{ automate_dv.link(src_pk=metadata_dict['src_pk'],\n"
                "                     src_fk=metadata_dict['src_fk'],\n"
                "                     src_ldts=metadata_dict['src_ldts'],\n"
                "                     src_source=metadata_dict['src_source'],\n"
                "                     source_model=metadata_dict['source_model']) }}\n"
                % (code, name, len(srcs), "\n".join("  - '%s'" % s for s in srcs), pk,
                   "\n".join("  - '%s'" % f for f in fk)))
        write(os.path.join(OP, "links", "lnk_%s.sql" % slug), text)
        report["built"][code] = srcs
        if code in DOUBTFUL:
            report["doubtful"][code] = DOUBTFUL[code]
    return report


# ----------------------------------------------------------------------------------- maximus_partner
def maximus():
    stg = os.path.join(MP, "staging")
    lks = os.path.join(MP, "link_staging")
    models = {}
    for f in sorted(glob.glob(os.path.join(stg, "stg2_mp__*.sql"))):
        m = read_yaml(f)
        hk, dc = m.get("hashed_columns") or {}, m.get("derived_columns") or {}
        out = collections.defaultdict(list)
        for k, v in hk.items():
            mm = re.match(r"([A-Z_]+?)_HKEY(__.*)?$", k)
            if isinstance(v, str) and mm:
                h, sfx = mm.group(1), mm.group(2) or ""
                if (h + "_BK" + sfx) in dc and (h + "_NK" + sfx) in dc:
                    out[h].append(sfx)
        models[os.path.basename(f)[:-4]] = out
    report = {"built": {}, "doubtful": {}}
    for code in MAX_LINKS:
        name, legs = LINKS[code]
        slug = code[4:].lower()
        pk = code[4:] + "_HKEY"
        ok = [t for t, s in models.items() if all(len(s.get(h, [])) == 1 for h in legs)]
        if not ok:
            report.setdefault("no_source", []).append(code)
            continue
        selects = []
        for t in ok:
            cols = ", ".join("%s_NK as %s_NK, %s_BK as %s_BK" % (h, h, h, h) for h in legs)
            where = " and ".join("%s_BK is not null" % h for h in legs)
            selects.append("    select %s,\n           LOAD_DATETIME, RECORD_SOURCE\n    from {{ ref('%s') }}\n    where %s"
                           % (cols, t, where))
        write(os.path.join(lks, "lnkbk_mp_%s.sql" % slug),
              "{{ config(materialized='view', tags=['lnk_extra']) }}\n"
              "-- BUILD-SIDE BUSINESS KEYS for %s (%s): %d feeder(s) over %d hub leg(s).\n"
              "-- Each feeder is a stg2_mp__ view in which every hub of this link has exactly ONE key slot.\n"
              "-- The NK columns are the hub stage models' own, so a leg and its hub are byte-identical.\n"
              "-- Written by generators/gen_partner_links_extra.py.\n" % (code, name, len(ok), len(legs))
              + "\nunion all\n".join(selects) + "\n")
        lines = ["{{ config(materialized='view', tags=['lnk_extra']) }}",
                 "-- stage() for %s: hub HKEYs (from each hub's own NK) and the link HKEY, over lnkbk_mp_%s." % (code, slug),
                 "-- Link NK = 'LNK_x|' || leg business keys, hubs in canonical-sheet order.",
                 "{%- set yaml_metadata -%}", "source_model: 'lnkbk_mp_%s'" % slug, "hashed_columns:"]
        lines += ["  %s_HKEY: '%s_NK'" % (h, h) for h in legs]
        lines.append("  %s: '%s_NK'" % (pk, code[4:]))
        lines.append("derived_columns:")
        lines.append("  %s_NK: %s" % (code[4:], q("'%s|' || " % code + " || '|' || ".join("%s_BK" % h for h in legs))))
        lines += ["{%- endset -%}", "{% set metadata_dict = fromyaml(yaml_metadata) %}",
                  "{{ automate_dv.stage(include_source_columns=true,",
                  "                      source_model=metadata_dict['source_model'],",
                  "                      hashed_columns=metadata_dict['hashed_columns'],",
                  "                      derived_columns=metadata_dict['derived_columns']) }}"]
        write(os.path.join(lks, "stg2_mp_lk__%s.sql" % slug), "\n".join(lines) + "\n")
        sel = ", ".join(["%s as %s" % (pk, pk)] + ["%s_HKEY as %s_HKEY" % (h, h) for h in legs])
        write(os.path.join(lks, "lnkfeed_mp_%s.sql" % slug),
              "{{ config(materialized='view', tags=['lnk_extra']) }}\n"
              "-- FEED for %s: %d feeder(s) over %d hub leg(s). BUILD-SIDE (not in the mapper's map);\n"
              "-- see lnkbk_mp_%s for the feeders and generators/gen_partner_links_extra.py for the rule.\n"
              "    select %s,\n           LOAD_DATETIME, RECORD_SOURCE\n"
              "    from {{ ref('stg2_mp_lk__%s') }}\n    where %s is not null\n"
              % (code, len(ok), len(legs), slug, sel, slug, pk))
        fk = "\n".join("  - '%s'" % f for f in sorted("%s_HKEY" % h for h in legs))
        write(os.path.join(MP, "links", "lnk_%s.sql" % slug),
              "{{ config(materialized='incremental', tags=['lnk_extra']) }}\n"
              "-- MAXIMUS PARTNER link() for %s. BUILD-SIDE: not in the mapper's map.\n"
              "-- Writes the SAME physical table as the OPUS build partner_dv_dbt's model of the same name: separate\n"
              "-- projects, separate pipelines, one shared vault. Declares ONLY this project's own sources.\n"
              "{%%- set yaml_metadata -%%}\nsource_model: 'lnkfeed_mp_%s'\nsrc_pk: '%s'\nsrc_fk:\n%s\n"
              "src_ldts: 'LOAD_DATETIME'\nsrc_source: 'RECORD_SOURCE'\n{%%- endset -%%}\n"
              "{%% set metadata_dict = fromyaml(yaml_metadata) %%}\n"
              "{{ automate_dv.link(src_pk=metadata_dict['src_pk'],\n"
              "                     src_fk=metadata_dict['src_fk'],\n"
              "                     src_ldts=metadata_dict['src_ldts'],\n"
              "                     src_source=metadata_dict['src_source'],\n"
              "                     source_model=metadata_dict['source_model']) }}\n" % (code, slug, pk, fk))
        report["built"][code] = ok
        if ok == ["stg2_mp__pd_prop_sp_pv"] or "stg2_mp__pd_prop_sp_pv" in ok:
            report["doubtful"][code] = DOUBTFUL_MAX
    return report


def main():
    rep = {"opus_partner": opus(), "maximus_partner": maximus()}
    write(REPORT, json.dumps(rep, indent=1) + "\n")
    for p, r in rep.items():
        print("%s: %d links, %d feeder models; no source: %s" % (
            p, len(r["built"]), sum(len(v) for v in r["built"].values()), r.get("no_source", "none")))


if __name__ == "__main__":
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass
    main()
