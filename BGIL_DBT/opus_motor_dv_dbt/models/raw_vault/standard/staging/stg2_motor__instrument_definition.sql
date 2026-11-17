-- automate_dv.stage() for SAT_INSTRUMENT_DEFINITION, read off central view stitch_motor__v06_distribution_channel.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v06_distribution_channel'
hashed_columns:
  PAYMENT_INSTRUMENT_HKEY: 'PAYMENT_INSTRUMENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ACCOUNT_HOLDER_NAME'
      - 'BANK_NAME'
      - 'BRANCH_NAME'
derived_columns:
  PAYMENT_INSTRUMENT_NK: "case when coalesce(INSTRUMENT_DEFINITION__ACCOUNT_HOLDER_NAME, INSTRUMENT_DEFINITION__BANK_NAME, INSTRUMENT_DEFINITION__BRANCH_NAME) is not null then 'HUB_PAYMENT_INSTRUMENT|' || PAYMENT_INSTRUMENT_BK end"
  ACCOUNT_HOLDER_NAME: 'INSTRUMENT_DEFINITION__ACCOUNT_HOLDER_NAME'
  BANK_NAME: 'INSTRUMENT_DEFINITION__BANK_NAME'
  BRANCH_NAME: 'INSTRUMENT_DEFINITION__BRANCH_NAME'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_motor__v06_distribution_channel'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
