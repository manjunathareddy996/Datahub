{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for HUB_RISK_OBJECT, traveller MEMBER1
-- branch of 'BJAZ_TRV_LOADER_DATA_MV'. Composite key POLICY_REF || '|' || 'MEMBERn'
-- per docs/TRAVEL_FIXES_APPLIED.md Fix 1 -- gives every traveller on a multi-traveller
-- policy their own HUB_RISK_OBJECT node instead of collapsing onto the payer party.

{%- set yaml_metadata -%}
source_model: 'stg_travel__bjaz_trv_loader_data_mv'
hashed_columns:
  RISK_OBJECT_HKEY: 'PARENT_NK'
derived_columns:
  PARENT_BK: "policy_ref || '|MEMBER1'"
  PARENT_NK: "'HUB_RISK_OBJECT|' || (policy_ref || '|MEMBER1')"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_TRV_LOADER_DATA_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
