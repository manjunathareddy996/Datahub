{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_POLICY_CLASSIFICATION, table 'BGIL_GMC_FINAL_INSTL_DATA' (union branch, no attribute-level merge needed).

{%- set yaml_metadata -%}
source_model: 'stg_health__bgil_gmc_final_instl_data'
hashed_columns:
  POLICY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CLASSIFICATION_VALUE'
derived_columns:
  PARENT_BK: 'policy_no'
  PARENT_NK: "'HUB_POLICY|' || (policy_no)"
  CLASSIFICATION_TYPE_CK: '!'
  CLASSIFICATION_VALUE: 'grade_bucket'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BGIL_GMC_FINAL_INSTL_DATA'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
