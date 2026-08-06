{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_COMMON_CONTACT, table 'BJAZ_HM_HOSP_MASTER_EXTN1' (union branch, no attribute-level merge needed).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_hosp_master_extn1'
hashed_columns:
  PARTY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'EMAIL_ADDRESS'
      - 'MOBILE_NUMBER'
derived_columns:
  PARENT_BK: 'hosid'
  PARENT_NK: "'HUB_PARTY|' || (hosid)"
  CONTACT_POINT_TYPE_CK: '!'
  CONTACT_PRIORITY_ORDER_CK: '!'
  EMAIL_ADDRESS: 'tpaemail'
  MOBILE_NUMBER: 'billingmobileno'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_HOSP_MASTER_EXTN1'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
