-- automate_dv.stage() for SAT_INSTRUMENT_DEFINITION, read off central view stitch_mxm__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v09_party'
hashed_columns:
  PAYMENT_INSTRUMENT_HKEY: 'PAYMENT_INSTRUMENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ACCOUNT_TYPE'
      - 'BANK_NAME'
      - 'CARD_TYPE'
      - 'IFSC_CODE'
      - 'INSTRUMENT_STATUS'
      - 'VALID_TO_DATE'
derived_columns:
  PAYMENT_INSTRUMENT_NK: "case when coalesce(INSTRUMENT_DEFINITION__ACCOUNT_TYPE, INSTRUMENT_DEFINITION__BANK_NAME, INSTRUMENT_DEFINITION__CARD_TYPE, INSTRUMENT_DEFINITION__IFSC_CODE, INSTRUMENT_DEFINITION__INSTRUMENT_STATUS, INSTRUMENT_DEFINITION__VALID_TO_DATE) is not null then 'HUB_PAYMENT_INSTRUMENT|' || PAYMENT_INSTRUMENT_BK end"
  ACCOUNT_TYPE: 'INSTRUMENT_DEFINITION__ACCOUNT_TYPE'
  BANK_NAME: 'INSTRUMENT_DEFINITION__BANK_NAME'
  CARD_TYPE: 'INSTRUMENT_DEFINITION__CARD_TYPE'
  IFSC_CODE: 'INSTRUMENT_DEFINITION__IFSC_CODE'
  INSTRUMENT_STATUS: 'INSTRUMENT_DEFINITION__INSTRUMENT_STATUS'
  VALID_TO_DATE: 'INSTRUMENT_DEFINITION__VALID_TO_DATE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v09_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
