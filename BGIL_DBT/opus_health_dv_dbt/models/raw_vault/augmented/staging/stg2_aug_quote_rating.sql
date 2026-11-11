-- automate_dv.stage() for SAT_AUG_QUOTE_RATING, read off central view stitch_v33_quote.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v33_quote'
hashed_columns:
  QUOTE_HKEY: 'QUOTE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'RATE_BASED_QUOTATION_INDICATOR'
derived_columns:
  QUOTE_NK: "case when AUG_QUOTE_RATING__RATE_BASED_QUOTATION_INDICATOR is not null then 'HUB_QUOTE|' || QUOTE_BK end"
  RATE_BASED_QUOTATION_INDICATOR: 'AUG_QUOTE_RATING__RATE_BASED_QUOTATION_INDICATOR'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v33_quote'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
