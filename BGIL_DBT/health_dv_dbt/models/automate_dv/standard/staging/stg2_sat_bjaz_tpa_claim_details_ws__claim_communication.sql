{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_CLAIM_COMMUNICATION, table 'BJAZ_TPA_CLAIM_DETAILS_WS' (single contributing table).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_tpa_claim_details_ws'
hashed_columns:
  CLAIM_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COMMUNICATION_DATE'
      - 'SUBJECT'
derived_columns:
  PARENT_BK: 'bjaz_claim_id'
  PARENT_NK: "'HUB_CLAIM|' || (bjaz_claim_id)"
  COMMUNICATION_DATE_CK: 'insured_disc_date'
  COMMUNICATION_DATE: 'insured_disc_date'
  SUBJECT: 'disc_datails'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_TPA_CLAIM_DETAILS_WS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
