-- automate_dv.stage() for SAT_QUOTE_RATING, read off central view stitch_motor__v23_quote.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v23_quote'
hashed_columns:
  QUOTE_HKEY: 'QUOTE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DISCOUNT_AMOUNT'
      - 'GROSS_PREMIUM'
      - 'INDICATIVE_DEDUCTIBLE'
      - 'LOADING_AMOUNT'
      - 'NET_PREMIUM'
derived_columns:
  QUOTE_NK: "case when coalesce(QUOTE_RATING__DISCOUNT_AMOUNT, QUOTE_RATING__GROSS_PREMIUM, QUOTE_RATING__INDICATIVE_DEDUCTIBLE, QUOTE_RATING__LOADING_AMOUNT, QUOTE_RATING__NET_PREMIUM) is not null then 'HUB_QUOTE|' || QUOTE_BK end"
  DISCOUNT_AMOUNT: 'QUOTE_RATING__DISCOUNT_AMOUNT'
  GROSS_PREMIUM: 'QUOTE_RATING__GROSS_PREMIUM'
  INDICATIVE_DEDUCTIBLE: 'QUOTE_RATING__INDICATIVE_DEDUCTIBLE'
  LOADING_AMOUNT: 'QUOTE_RATING__LOADING_AMOUNT'
  NET_PREMIUM: 'QUOTE_RATING__NET_PREMIUM'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_stitch_motor__v23_quote'
  SOURCE_SYSTEM: '!OPUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
