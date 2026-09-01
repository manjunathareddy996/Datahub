{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for SAT_PARTY_HEALTH_PROFILE, table 'BA_TRV_DATA_POLICY_DTLS_MV' (payer anchor).

{%- set yaml_metadata -%}
source_model: 'stg_travel__ba_trv_data_policy_dtls_mv'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PRE_EXISTING_DISEASE_DESCRIPTION'
derived_columns:
  PARENT_BK: 'payer_part_id'
  PARENT_NK: "'HUB_PARTY|' || (payer_part_id)"
  PRE_EXISTING_DISEASE_DESCRIPTION: 'disease_codes'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!BA_TRV_DATA_POLICY_DTLS_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
