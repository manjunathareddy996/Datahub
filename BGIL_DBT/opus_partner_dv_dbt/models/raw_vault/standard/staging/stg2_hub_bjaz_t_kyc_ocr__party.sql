{{ config(materialized='view') }}

-- PARTNER+KYC per-table stage() for HUB_PARTY, branch 'BJAZ_T_KYC_OCR'.
-- Identifiers localised to the staging aliases.
--
-- KYC-SUBJECT PARTY KEY: FORM RATIFIED, SEMANTICS UNVERIFIED (KEY_FORM_RATIFIED_SEMANTICS_UNVERIFIED).
-- Operands on this table: FIELD_TYPE / FIELD_VALUE, selected by the ratified rule -- first COMPLETE pair
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
-- One line to switch this table off: pkyc_party_key.ENABLED['BJAZ_T_KYC_OCR'] = False.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_t_kyc_ocr'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
derived_columns:
  PARENT_BK: "nullif(upper(trim(coalesce(field_type,''))) || ':' || upper(trim(coalesce(field_value,''))), ':')"
  PARENT_NK: "'HUB_PARTY|' || (nullif(upper(trim(coalesce(field_type,''))) || ':' || upper(trim(coalesce(field_value,''))), ':'))"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_BJAZ_T_KYC_OCR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
