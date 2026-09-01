{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for SAT_POLICY_CLASSIFICATION, table 'BJAZ_TRV_LOADER_DATA_MV', column 'FAMILYFLAG' -> Classification Value [{'CLASSIFICATION_TYPE': 'family_plan'}].

{%- set yaml_metadata -%}
source_model: 'stg_travel__bjaz_trv_loader_data_mv'
hashed_columns:
  POLICY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CLASSIFICATION_VALUE'
      - 'CLASSIFICATION_TYPE'
derived_columns:
  PARENT_BK: 'policy_ref'
  PARENT_NK: "'HUB_POLICY|' || (policy_ref)"
  CLASSIFICATION_TYPE: '!family_plan'
  CLASSIFICATION_VALUE: 'familyflag'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!BJAZ_TRV_LOADER_DATA_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
