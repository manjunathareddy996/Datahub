-- automate_dv.stage() for SAT_AUG_FINTXN_TAX, read off central view stitch_v04_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v04_claim'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DIFFERENTIAL_TDS_INDICATOR'
      - 'TAX_TYPE_CK'
derived_columns:
  FINANCIAL_TRANSACTION_NK: "case when AUG_FINTXN_TAX__DIFFERENTIAL_TDS_INDICATOR is not null then 'HUB_FINANCIAL_TRANSACTION|' || FINANCIAL_TRANSACTION_BK end"
  TAX_TYPE_CK: 'AUG_FINTXN_TAX__TAX_TYPE_CK'
  DIFFERENTIAL_TDS_INDICATOR: 'AUG_FINTXN_TAX__DIFFERENTIAL_TDS_INDICATOR'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v04_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
