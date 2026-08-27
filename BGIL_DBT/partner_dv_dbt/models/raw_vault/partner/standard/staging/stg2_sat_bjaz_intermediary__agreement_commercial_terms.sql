{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() for SAT_AGREEMENT_COMMERCIAL_TERMS, table 'BJAZ_INTERMEDIARY'.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_intermediary'
hashed_columns:
  AGREEMENT_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COMMISSIONSTRUCTURE'
derived_columns:
  PARENT_BK: 'intermediary_id'
  PARENT_NK: "'HUB_AGREEMENT|' || (intermediary_id)"
  COMMISSIONSTRUCTURE: 'type_of_comm_arr'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!BJAZ_INTERMEDIARY'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
