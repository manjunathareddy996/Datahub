{{ config(materialized='view') }}

-- PARTNER+KYC per-table stage() for SAT_PARTY_KYC_REFERENCE, table 'BJAZ_T_CKYC_REL_PERSION_DTLS'.
-- Anchor HUB_PARTY, taken from data_7's parent field -- NOT from the satellite's name.
-- Payload rendered GLUED because the anchor is a HUB (DEC-01, counted from the baseline:
-- 131 hub-anchored GLUED, 23 link-anchored UNDERSCORED, 0 counterexamples).
--
-- Null-padded TO THE SATELLITE, not to this feeder (BUILD_RULES.md 6): 1 of 1
-- payload column(s) are not carried by BJAZ_T_CKYC_REL_PERSION_DTLS and are emitted as a typed NULL so
-- the HASHDIFF column list is identical across every branch of the union.
-- Padded: KYCREFERENCETYPE.
--
-- DEC-08 / BDEC-01: this scope's grain for SAT_PARTY_KYC_REFERENCE is BASELINE_GRAIN_SINGLE_ACTIVE_UNDER_KEYED.
-- data_7 declares this satellite MULTI-ACTIVE on childkey 'KYC Reference Type', and this scope
-- builds it SINGLE-ACTIVE to match the baseline rows a builder has already
-- loaded. COST, STATED: two KYC reference types for one party overwrite each
-- other here. The leg stays a PAYLOAD column, which is what those loaded rows
-- were hashed with; promoting it to src_cdk would re-chain the hashdiff.
-- One line to change: KR.SWITCHES['SAT_PARTY_KYC_REFERENCE_GRAIN']['merged'].
--
-- KYC-SUBJECT PARTY KEY: BUILDER ASSUMPTION A1 (KEY_FORM_BUILDER_ASSUMED).
-- NOT RATIFIED BY ANYONE. This is the caller's decision to complete the build on a
-- documented assumption, and it is a DIFFERENT STANDING from the ten tables whose
-- form the mapping counterparty ratified (KEY_FORM_RATIFIED_SEMANTICS_UNVERIFIED).
--
-- WHAT: key HUB_PARTY on the centrally-issued CKYC number
-- EXPRESSION: nullif('CKYC:' || upper(trim(coalesce(ckyc_no,''))), 'CKYC:')
--
-- WHY: The CKYC number is a centrally-issued canonical KYC identifier and is the ONLY
-- party identifier either of these two tables declares; they carry no CATEGORY/INPUT, no
-- SEARCH_* and no FIELD_* pair.
--
-- RISK 1: A BLANK CKYC_NO is REJECTED by the nullif guard rather than keyed, so those
-- rows produce a NULL business key and AutomateDV will hash one bogus hub row per source
-- rather than silently merging them. Visible, not silent.
--
-- RISK 2: IF CKYC_NO IS NOT UNIQUE PER PARTY the hub OVER-MERGES: two different people
-- sharing a CKYC number become one party, and no check in this build can see it because
-- uniqueness is a property of the data, not of the schema.
--
-- RISK 3: These are the ONLY TWO TABLES IN THE PACK DECLARING NO PRIMARY KEY AT ALL
-- (build_profile.json ddl_profile.tables_with_no_resolvable_pk), so there is no row key
-- either: the satellite grain rests on the child key alone, and where no child key
-- resolves the unit stays refused rather than collapsing onto one row.
--
-- CONFIRM WITH: the source owner, on CKYC_NO's uniqueness per party.
-- ONE LINE TO OVERRULE: pkyc_party_key.ASSUMPTIONS_ENABLED['A1'] = False
--
-- ONE HUB, THREE KEY-SPACE PRODUCERS. HUB_PARTY is now keyed by the ratified
-- CATEGORY:INPUT form on 10 tables, by 'CKYC:<number>' under A1 on 2, and by
-- '<TYPE>:<number>' under A2 on 5. Whether a person reached through two of those routes
-- lands on ONE hub row depends entirely on whether CATEGORY's value vocabulary spells
-- the document type the same way A1 and A2 do -- which is the undetermined
-- identifier-versus-search-term question. If it does, the spaces coincide by design. If
-- it does not, the same person is two parties and nothing in this build can see it.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_t_ckyc_rel_persion_dtls'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'KYCREFERENCETYPE'
derived_columns:
  PARENT_BK: "nullif('CKYC:' || upper(trim(coalesce(ckyc_no,''))), 'CKYC:')"
  PARENT_NK: "'HUB_PARTY|' || (nullif('CKYC:' || upper(trim(coalesce(ckyc_no,''))), 'CKYC:'))"
  KYCREFERENCETYPE: "cast(null as varchar)"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_BJAZ_T_CKYC_REL_PERSION_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
