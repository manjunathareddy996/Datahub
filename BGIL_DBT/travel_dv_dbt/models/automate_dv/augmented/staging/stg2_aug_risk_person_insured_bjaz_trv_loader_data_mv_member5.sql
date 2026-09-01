{{ config(materialized='view') }}

-- TRAVEL AUGMENTED per-table stage() for SAT_AUG_RISK_PERSON_INSURED,
-- table 'BJAZ_TRV_LOADER_DATA_MV', traveller MEMBER5. Reuses the same
-- POLICY_REF || '|MEMBER5' composite as the standard-model risk-object build.

{%- set yaml_metadata -%}
source_model: 'stg_travel__bjaz_trv_loader_data_mv'
hashed_columns:
  RISK_OBJECT_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DATE_OF_BIRTH'
derived_columns:
  PARENT_BK: 'policy_ref || '|member5''
  PARENT_NK: "'HUB_RISK_OBJECT|' || (policy_ref || '|member5')"
  DATE_OF_BIRTH: 'member5dob'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!BJAZ_TRV_LOADER_DATA_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
