{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_PARTY_POLICY_HISTORY, table 'BJAZ_EC_MEM_DTLS_EXTN' (single contributing table).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_ec_mem_dtls_extn'
hashed_columns:
  PARTY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CONTINUOUS_YEARS_INSURED'
derived_columns:
  PARENT_BK: 'member_no'
  PARENT_NK: "'HUB_PARTY|' || (member_no)"
  CONTINUOUS_YEARS_INSURED: 'hlth_ins_pol_yrs'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_EC_MEM_DTLS_EXTN'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
