{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_COMMON_CONTACT, table 'BA_HCP_PROD_8439_CLH_LOADER' (union branch, no attribute-level merge needed).

{%- set yaml_metadata -%}
source_model: 'stg_health__ba_hcp_prod_8439_clh_loader'
hashed_columns:
  PARTY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'EMAIL_ADDRESS'
      - 'FAX_NUMBER'
      - 'LANDLINE_NUMBER'
      - 'MOBILE_NUMBER'
derived_columns:
  PARENT_BK: 'pd_premium_payer_id'
  PARENT_NK: "'HUB_PARTY|' || (pd_premium_payer_id)"
  CONTACT_POINT_TYPE_CK: '!'
  CONTACT_PRIORITY_ORDER_CK: '!'
  EMAIL_ADDRESS: 'pd_email'
  FAX_NUMBER: 'pd_fax'
  LANDLINE_NUMBER: 'pd_telephone'
  MOBILE_NUMBER: 'pd_mobile_number'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_HCP_PROD_8439_CLH_LOADER'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
