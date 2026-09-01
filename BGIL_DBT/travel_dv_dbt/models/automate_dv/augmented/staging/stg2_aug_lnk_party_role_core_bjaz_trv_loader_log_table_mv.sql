{{ config(materialized='view') }}

-- TRAVEL AUGMENTED per-table stage() for SAT_AUG_LNK_PARTY_ROLE_CORE.
-- Canonical SAT_LNK_PARTY_ROLE_CORE has childkey "Role Code + Role Sequence" -- no
-- real sequence data exists here, so this is built role-special-style (literal
-- ROLE_TYPE_CK, not a genuine multi-active sequence) rather than fabricating one.

{%- set yaml_metadata -%}
source_model: 'stg_travel__bjaz_trv_loader_log_table_mv'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PREMIUM_PAYER_INDICATOR'
derived_columns:
  PARENT_BK: 'premiumpayerid'
  PARENT_NK: "'HUB_PARTY|' || (premiumpayerid)"
  ROLE_TYPE_CK: '!premium-payer'
  PREMIUM_PAYER_INDICATOR: 'premiumpayerflag'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_TRV_LOADER_LOG_TABLE_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
