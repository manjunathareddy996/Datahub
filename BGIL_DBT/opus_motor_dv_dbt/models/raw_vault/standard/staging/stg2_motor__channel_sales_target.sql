-- automate_dv.stage() for SAT_CHANNEL_SALES_TARGET, read off central view stitch_motor__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v09_party'
hashed_columns:
  DISTRIBUTION_CHANNEL_HKEY: 'DISTRIBUTION_CHANNEL_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BUDGET_AMOUNT'
      - 'BUDGET_PERCENTAGE'
      - 'TARGET_PERIOD'
      - 'TARGET_TYPE'
      - 'TARGET_PERIOD_CK'
      - 'TARGET_TYPE_CK'
derived_columns:
  DISTRIBUTION_CHANNEL_NK: "case when coalesce(CHANNEL_SALES_TARGET__BUDGET_AMOUNT, CHANNEL_SALES_TARGET__BUDGET_PERCENTAGE, CHANNEL_SALES_TARGET__TARGET_PERIOD, CHANNEL_SALES_TARGET__TARGET_TYPE) is not null then 'HUB_DISTRIBUTION_CHANNEL|' || DISTRIBUTION_CHANNEL_BK end"
  TARGET_PERIOD_CK: 'CHANNEL_SALES_TARGET__TARGET_PERIOD_CK'
  TARGET_TYPE_CK: 'CHANNEL_SALES_TARGET__TARGET_TYPE_CK'
  BUDGET_AMOUNT: 'CHANNEL_SALES_TARGET__BUDGET_AMOUNT'
  BUDGET_PERCENTAGE: 'CHANNEL_SALES_TARGET__BUDGET_PERCENTAGE'
  TARGET_PERIOD: 'CHANNEL_SALES_TARGET__TARGET_PERIOD'
  TARGET_TYPE: 'CHANNEL_SALES_TARGET__TARGET_TYPE'
  LOAD_DATETIME: 'DISTRIBUTION_CHANNEL_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!OPUS_stitch_motor__v09_party'
  SOURCE_SYSTEM: '!OPUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
