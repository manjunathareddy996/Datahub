{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_POLICY_CERTIFICATE, table 'BJAZ_HM_HCM_EXTRACT' (union branch, no attribute-level merge needed).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_hcm_extract'
hashed_columns:
  POLICY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'MEMBER_PREMIUM'
derived_columns:
  PARENT_BK: 'policy'
  PARENT_NK: "'HUB_POLICY|' || (policy)"
  CERTIFICATE_NUMBER_CK: '!'
  MEMBER_PREMIUM: 'premium'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_HCM_EXTRACT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
