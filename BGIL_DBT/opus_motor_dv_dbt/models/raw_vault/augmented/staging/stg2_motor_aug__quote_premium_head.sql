-- automate_dv.stage() for SAT_AUG_QUOTE_PREMIUM_HEAD, read off central view stitch_motor__v22_quote.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v22_quote'
hashed_columns:
  QUOTE_HKEY: 'QUOTE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'NET_HEAD_PREMIUM'
      - 'PREMIUM_COMPONENT'
      - 'PREMIUM_HEAD_CODE'
      - 'PREMIUM_HEAD_NAME'
      - 'PREMIUM_HEAD_CODE_CK'
      - 'SECTION_CK'
derived_columns:
  QUOTE_NK: "case when coalesce(AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM, AUG_QUOTE_PREMIUM_HEAD__PREMIUM_COMPONENT, AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE, AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_NAME) is not null then 'HUB_QUOTE|' || QUOTE_BK end"
  PREMIUM_HEAD_CODE_CK: 'AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK'
  SECTION_CK: 'AUG_QUOTE_PREMIUM_HEAD__SECTION_CK'
  NET_HEAD_PREMIUM: 'AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM'
  PREMIUM_COMPONENT: 'AUG_QUOTE_PREMIUM_HEAD__PREMIUM_COMPONENT'
  PREMIUM_HEAD_CODE: 'AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE'
  PREMIUM_HEAD_NAME: 'AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_NAME'
  LOAD_DATETIME: 'AUG_QUOTE_PREMIUM_HEAD__LOAD_DATETIME'
  RECORD_SOURCE: '!stitch_motor__v22_quote'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
