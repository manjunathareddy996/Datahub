-- automate_dv.stage() for SAT_QUOTE_RATING_INPUT, read off central view stitch_motor__v22_quote.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v22_quote'
hashed_columns:
  QUOTE_HKEY: 'QUOTE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'FACTOR_VALUE'
      - 'FACTOR_CODE'
derived_columns:
  QUOTE_NK: "case when QUOTE_RATING_INPUT__FACTOR_VALUE is not null then 'HUB_QUOTE|' || QUOTE_BK end"
  FACTOR_CODE: 'QUOTE_RATING_INPUT__FACTOR_CODE_CK'
  FACTOR_VALUE: 'QUOTE_RATING_INPUT__FACTOR_VALUE'
  LOAD_DATETIME: 'QUOTE_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!OPUS_stitch_motor__v22_quote'
  SOURCE_SYSTEM: '!OPUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
