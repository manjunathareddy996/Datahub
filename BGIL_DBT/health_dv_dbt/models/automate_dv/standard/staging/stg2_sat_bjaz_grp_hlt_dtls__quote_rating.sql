{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_QUOTE_RATING, table 'BJAZ_GRP_HLT_DTLS' (single contributing table).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_grp_hlt_dtls'
hashed_columns:
  QUOTE_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DISCOUNT_AMOUNT'
      - 'GROSS_PREMIUM'
      - 'TOTAL_ANNUAL_PREMIUM'
derived_columns:
  PARENT_BK: 'quote_sub_no'
  PARENT_NK: "'HUB_QUOTE|' || (quote_sub_no)"
  DISCOUNT_AMOUNT: 'ho_discount'
  GROSS_PREMIUM: 'prem_quoted'
  TOTAL_ANNUAL_PREMIUM: 'discounted_premium'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_GRP_HLT_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
