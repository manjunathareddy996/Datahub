{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() for HUB_RISK_OBJECT branch 'CLM_INTERESTED_PARTIES'.
-- Provenance: explicit.

{%- set yaml_metadata -%}
source_model: 'stg_partner__clm_interested_parties'
hashed_columns:
  RISK_OBJECT_HKEY: 'PARENT_NK'
derived_columns:
  PARENT_BK: 'ins_obj_uid'
  PARENT_NK: "'HUB_RISK_OBJECT|' || (ins_obj_uid)"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!CLM_INTERESTED_PARTIES'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
