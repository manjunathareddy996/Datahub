-- automate_dv.stage() for SAT_MOTOR_AUG_FIN_RECEIPT, read off central view stitch_mxm__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v09_party'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COLLECTION_DATE'
      - 'COLLECTION_SOURCE'
      - 'COLLECTION_SUB_CODE'
derived_columns:
  FINANCIAL_TRANSACTION_NK: "case when coalesce(AUG_FIN_RECEIPT__COLLECTION_DATE, AUG_FIN_RECEIPT__COLLECTION_SOURCE, AUG_FIN_RECEIPT__COLLECTION_SUB_CODE) is not null then 'HUB_FINANCIAL_TRANSACTION|' || FINANCIAL_TRANSACTION_BK end"
  COLLECTION_DATE: 'AUG_FIN_RECEIPT__COLLECTION_DATE'
  COLLECTION_SOURCE: 'AUG_FIN_RECEIPT__COLLECTION_SOURCE'
  COLLECTION_SUB_CODE: 'AUG_FIN_RECEIPT__COLLECTION_SUB_CODE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v09_party'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
