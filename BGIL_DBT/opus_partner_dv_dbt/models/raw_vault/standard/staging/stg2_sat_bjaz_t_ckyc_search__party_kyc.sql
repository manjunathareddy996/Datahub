{{ config(materialized='view') }}

-- PARTNER+KYC per-table stage() for SAT_PARTY_KYC, table 'BJAZ_T_CKYC_SEARCH'.
-- Anchor HUB_PARTY, taken from data_7's parent field -- NOT from the satellite's name.
-- Payload rendered GLUED because the anchor is a HUB (DEC-01, counted from the baseline:
-- 131 hub-anchored GLUED, 23 link-anchored UNDERSCORED, 0 counterexamples).
--
-- Null-padded TO THE SATELLITE, not to this feeder (BUILD_RULES.md 6): 4 of 8
-- payload column(s) are not carried by BJAZ_T_CKYC_SEARCH and are emitted as a typed NULL so
-- the HASHDIFF column list is identical across every branch of the union.
-- Padded: KYCMODE, KYCSTATUS, KYCTYPE, OVDSUBMITTEDCOUNT.
--
-- GRAIN CONFLICT, BUILT AS MAPPED AND RAISED (BUILD_RULES.md 5.7):
-- 1 attribute(s) of this single-active satellite are written by this table AND
-- by BJAZ_T_KYC_DETAILS under a BYTE-IDENTICAL HUB_PARTY key, with an EMPTY discriminator.
-- One load silently overwrites the other. The builder does not choose between
-- two writers -- that IS the mapping decision. Attributes: KYC Completion Date.
--
-- KYC-SUBJECT PARTY KEY: FORM RATIFIED, SEMANTICS UNVERIFIED (KEY_FORM_RATIFIED_SEMANTICS_UNVERIFIED).
-- Operands on this table: CATEGORY / INPUT, selected by the ratified rule -- first COMPLETE pair
-- of (CATEGORY, INPUT), (SEARCH_CATEGORY, SEARCH_INPUT), (FIELD_TYPE, FIELD_VALUE).
-- Re-derived from the source DDL and asserted against the ratified table pair for pair;
-- a disagreement fails the build. Authority: ratified by the mapping counterparty on its caller's authority; re-derived from inputs/KYC_Tables_source_ddl.xlsx and asserted against the counterparty's table pair for pair at import time.
--
-- THE nullif(..., ':') GUARD IS PART OF THE KEY, NOT DECORATION. Without it an all-blank
-- row reduces to the bare constant ':' and every such row keys to ONE party.
--
-- UNDETERMINED, AND SETTLEABLE ONLY BY THE SOURCE OWNER: is this pair an identifier TYPE
-- and VALUE, or a record of what was SEARCHED FOR? If the latter, keying HUB_PARTY on it
-- MERGES EVERY PARTY EVER SEARCHED BY THE SAME VALUE. Built as mapped and raised (5.7).
-- BJAZ_T_KYC_INCOMING IS THE ROW TO CHANGE FIRST: it is the request root and its
-- SEARCH_CATEGORY is VARCHAR2(2) against CATEGORY's 10 or 20, so a two-character category
-- reads more like a search-type flag than an identifier type. Refusing the request root
-- would strand the 8 tables that foreign-key to INCOMING_ID, so it is built.
-- One line to switch this table off: pkyc_party_key.ENABLED['BJAZ_T_CKYC_SEARCH'] = False.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_t_ckyc_search'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CKYCNUMBER'
      - 'CKYCREGISTRATIONSTATUS'
      - 'KYCCOMPLETIONDATE'
      - 'KYCMODE'
      - 'KYCSTATUS'
      - 'KYCTYPE'
      - 'LASTKYCREVIEWDATE'
      - 'OVDSUBMITTEDCOUNT'
derived_columns:
  PARENT_BK: "nullif(upper(trim(coalesce(category,''))) || ':' || upper(trim(coalesce(input,''))), ':')"
  PARENT_NK: "'HUB_PARTY|' || (nullif(upper(trim(coalesce(category,''))) || ':' || upper(trim(coalesce(input,''))), ':'))"
  CKYCNUMBER: 'ckyc_number'
  CKYCREGISTRATIONSTATUS: 'ckyc_status'
  KYCCOMPLETIONDATE: 'ckyc_kyc_date'
  KYCMODE: "cast(null as varchar)"
  KYCSTATUS: "cast(null as varchar)"
  KYCTYPE: "cast(null as varchar)"
  LASTKYCREVIEWDATE: 'ckyc_update_date'
  OVDSUBMITTEDCOUNT: "cast(null as varchar)"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_BJAZ_T_CKYC_SEARCH'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
