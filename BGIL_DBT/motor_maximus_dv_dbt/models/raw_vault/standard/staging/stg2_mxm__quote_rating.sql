-- automate_dv.stage() for SAT_QUOTE_RATING, read off central view stitch_mxm__v11_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v11_party'
hashed_columns:
  QUOTE_HKEY: 'QUOTE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BASE_PREMIUM'
      - 'DISCOUNT_AMOUNT'
      - 'GROSS_PREMIUM'
      - 'GST_AMOUNT'
      - 'LOADING_AMOUNT'
      - 'NET_PREMIUM'
      - 'PREMIUM_FREQUENCY'
derived_columns:
  QUOTE_NK: "case when coalesce(QUOTE_RATING__BASE_PREMIUM, QUOTE_RATING__DISCOUNT_AMOUNT, QUOTE_RATING__GROSS_PREMIUM, QUOTE_RATING__GST_AMOUNT, QUOTE_RATING__LOADING_AMOUNT, QUOTE_RATING__NET_PREMIUM, QUOTE_RATING__PREMIUM_FREQUENCY) is not null then 'HUB_QUOTE|' || QUOTE_BK end"
  BASE_PREMIUM: 'QUOTE_RATING__BASE_PREMIUM'
  DISCOUNT_AMOUNT: 'QUOTE_RATING__DISCOUNT_AMOUNT'
  GROSS_PREMIUM: 'QUOTE_RATING__GROSS_PREMIUM'
  GST_AMOUNT: 'QUOTE_RATING__GST_AMOUNT'
  LOADING_AMOUNT: 'QUOTE_RATING__LOADING_AMOUNT'
  NET_PREMIUM: 'QUOTE_RATING__NET_PREMIUM'
  PREMIUM_FREQUENCY: 'QUOTE_RATING__PREMIUM_FREQUENCY'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v11_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
