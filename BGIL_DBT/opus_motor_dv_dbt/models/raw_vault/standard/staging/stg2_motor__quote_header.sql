-- automate_dv.stage() for SAT_QUOTE_HEADER, read off central view stitch_motor__v23_quote.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v23_quote'
hashed_columns:
  QUOTE_HKEY: 'QUOTE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CONVERSION_STATUS'
      - 'PROSPECT_REFERENCE'
      - 'QUOTE_CHANNEL'
      - 'QUOTE_DATE'
      - 'QUOTE_REFERENCE_SOURCE'
      - 'QUOTE_SOURCE'
      - 'QUOTE_STATUS'
      - 'REQUESTED_SUM_INSURED'
derived_columns:
  QUOTE_NK: "case when coalesce(QUOTE_HEADER__CONVERSION_STATUS, QUOTE_HEADER__PROSPECT_REFERENCE, QUOTE_HEADER__QUOTE_CHANNEL, QUOTE_HEADER__QUOTE_DATE, QUOTE_HEADER__QUOTE_REFERENCE_SOURCE, QUOTE_HEADER__QUOTE_SOURCE, QUOTE_HEADER__QUOTE_STATUS, QUOTE_HEADER__REQUESTED_SUM_INSURED) is not null then 'HUB_QUOTE|' || QUOTE_BK end"
  CONVERSION_STATUS: 'QUOTE_HEADER__CONVERSION_STATUS'
  PROSPECT_REFERENCE: 'QUOTE_HEADER__PROSPECT_REFERENCE'
  QUOTE_CHANNEL: 'QUOTE_HEADER__QUOTE_CHANNEL'
  QUOTE_DATE: 'QUOTE_HEADER__QUOTE_DATE'
  QUOTE_REFERENCE_SOURCE: 'QUOTE_HEADER__QUOTE_REFERENCE_SOURCE'
  QUOTE_SOURCE: 'QUOTE_HEADER__QUOTE_SOURCE'
  QUOTE_STATUS: 'QUOTE_HEADER__QUOTE_STATUS'
  REQUESTED_SUM_INSURED: 'QUOTE_HEADER__REQUESTED_SUM_INSURED'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_motor__v23_quote'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
