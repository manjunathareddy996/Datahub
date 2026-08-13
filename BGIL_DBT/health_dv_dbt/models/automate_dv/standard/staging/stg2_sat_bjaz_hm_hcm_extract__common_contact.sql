{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_COMMON_CONTACT, table 'BJAZ_HM_HCM_EXTRACT' (union branch, no attribute-level merge needed).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_hcm_extract'
hashed_columns:
  PARTY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'FAX_NUMBER'
      - 'LANDLINE_NUMBER'
      - 'MOBILE_NUMBER'
      - 'STD_CODE'
derived_columns:
  PARENT_BK: 'hospital_id'
  PARENT_NK: "'HUB_PARTY|' || (hospital_id)"
  CONTACT_POINT_TYPE_CK: '!'
  CONTACT_PRIORITY_ORDER_CK: '!'
  FAX_NUMBER: 'fax'
  LANDLINE_NUMBER: 'phone'
  MOBILE_NUMBER: 'mobile_no'
  STD_CODE: 'std'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_HCM_EXTRACT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
