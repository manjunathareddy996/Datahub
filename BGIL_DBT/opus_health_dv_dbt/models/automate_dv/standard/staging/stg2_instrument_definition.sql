-- automate_dv.stage() for SAT_INSTRUMENT_DEFINITION, read off central view stitch_v09_claim.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v09_claim'
hashed_columns:
  PAYMENT_INSTRUMENT_HKEY: 'PAYMENT_INSTRUMENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CARD_NUMBER_MASKED'
derived_columns:
  PAYMENT_INSTRUMENT_NK: "case when INSTRUMENT_DEFINITION__CARD_NUMBER_MASKED is not null then 'HUB_PAYMENT_INSTRUMENT|' || PAYMENT_INSTRUMENT_BK end"
  CARD_NUMBER_MASKED: 'INSTRUMENT_DEFINITION__CARD_NUMBER_MASKED'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v09_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
