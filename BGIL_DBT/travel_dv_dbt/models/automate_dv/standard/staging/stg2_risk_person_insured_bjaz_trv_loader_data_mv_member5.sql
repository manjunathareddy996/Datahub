{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for SAT_RISK_PERSON_INSURED, table 'BJAZ_TRV_LOADER_DATA_MV', traveller MEMBER5.

{%- set yaml_metadata -%}
source_model: 'stg_travel__bjaz_trv_loader_data_mv'
hashed_columns:
  RISK_OBJECT_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PRE_EXISTING_DISEASE_DESCRIPTION'
      - 'GENDER'
      - 'INSURED_MEMBER_NAME'
      - 'RELATIONSHIP_TO_PROPOSER'
derived_columns:
  PARENT_BK: "policy_ref || '|MEMBER5'"
  PARENT_NK: "'HUB_RISK_OBJECT|' || (policy_ref || '|MEMBER5')"
  PRE_EXISTING_DISEASE_DESCRIPTION: 'member5desease'
  GENDER: 'member5gender'
  INSURED_MEMBER_NAME: 'member5name'
  RELATIONSHIP_TO_PROPOSER: 'member5relation'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_TRV_LOADER_DATA_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
