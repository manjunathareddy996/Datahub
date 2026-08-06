{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_PARTY_GROUP_CENSUS, table 'BJAZ_HM_MEMBER_DTLS' (union branch, no attribute-level merge needed).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_member_dtls'
hashed_columns:
  PARTY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DESIGNATION_BAND'
      - 'EMPLOYEE_ID'
      - 'LOCATION_REFERENCE'
derived_columns:
  PARENT_BK: 'member_id'
  PARENT_NK: "'HUB_PARTY|' || (member_id)"
  MEMBER_REFERENCE_CK: '!'
  DESIGNATION_BAND: 'grade'
  EMPLOYEE_ID: 'hat_empcode'
  LOCATION_REFERENCE: 'employee_location'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_MEMBER_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
