-- automate_dv.stage() for SAT_PRODUCT_UW_RULE, read off central view stitch_v15_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v15_policy'
hashed_columns:
  PRODUCT_HKEY: 'PRODUCT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'TRIGGER_CONDITION'
      - 'ACTIVE_SEQUENCE_NUMBER_CK'
derived_columns:
  PRODUCT_NK: "case when PRODUCT_UW_RULE__TRIGGER_CONDITION is not null then 'HUB_PRODUCT|' || PRODUCT_BK end"
  ACTIVE_SEQUENCE_NUMBER_CK: 'PRODUCT_UW_RULE__ACTIVE_SEQUENCE_NUMBER_CK'
  TRIGGER_CONDITION: 'PRODUCT_UW_RULE__TRIGGER_CONDITION'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v15_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
