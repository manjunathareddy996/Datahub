{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() for SAT_LNK_ROLE_AGENT, table 'BJAZ_INTERMEDIARY_HIST'.
-- role-special: built directly off HUB_PARTY with a literal role_type_ck
-- ('agent') -- same modelling deviation ratified for Health (M3): a
-- load-time provenance label, not a fabricated business key.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_intermediary_hist'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AGENT_CODE'
      - 'IRDAI_AGENT_LICENCE_NUMBER'
      - 'LICENCE_EXPIRY_DATE'
      - 'LICENCE_ISSUE_DATE'
      - 'LICENCE_CATEGORY'
derived_columns:
  PARENT_BK: 'intermediary_id'
  PARENT_NK: "'HUB_PARTY|' || (intermediary_id)"
  ROLE_TYPE_CK: '!agent'
  AGENT_CODE: 'irda_intermediary_code'
  IRDAI_AGENT_LICENCE_NUMBER: 'irda_license_no'
  LICENCE_EXPIRY_DATE: 'license_expiry_date'
  LICENCE_ISSUE_DATE: 'license_issue_date'
  LICENCE_CATEGORY: 'license_type'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_INTERMEDIARY_HIST'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
