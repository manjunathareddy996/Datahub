{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_COMMON_CONTACT, table 'BJAZ_BANDHAN_MEDI_CLAM' (union branch, no attribute-level merge needed).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_bandhan_medi_clam'
hashed_columns:
  PARTY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ALTERNATE_EMAIL_ADDRESS'
      - 'ALTERNATE_MOBILE_NUMBER'
      - 'EMAIL_ADDRESS'
      - 'MOBILE_NUMBER'
derived_columns:
  PARENT_BK: 'customer_id'
  PARENT_NK: "'HUB_PARTY|' || (customer_id)"
  CONTACT_POINT_TYPE_CK: '!'
  CONTACT_PRIORITY_ORDER_CK: '!'
  ALTERNATE_EMAIL_ADDRESS: 'm_email'
  ALTERNATE_MOBILE_NUMBER: 'm_mobile'
  EMAIL_ADDRESS: 'p_email'
  MOBILE_NUMBER: 'mobile'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_BANDHAN_MEDI_CLAM'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
