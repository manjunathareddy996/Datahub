-- automate_dv.stage() for SAT_MOTOR_AUG_FINTXN_CHANNEL_AUTHORISATION, read off central view stitch_motor__v11_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v11_party'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AUTHORISATION_PIN_DATE'
      - 'AUTHORISATION_PIN_NUMBER'
      - 'AUTHORISATION_PIN_STATUS'
derived_columns:
  FINANCIAL_TRANSACTION_NK: "case when coalesce(AUG_FINTXN_CHANNEL_AUTHORISATION__AUTHORISATION_PIN_DATE, AUG_FINTXN_CHANNEL_AUTHORISATION__AUTHORISATION_PIN_NUMBER, AUG_FINTXN_CHANNEL_AUTHORISATION__AUTHORISATION_PIN_STATUS) is not null then 'HUB_FINANCIAL_TRANSACTION|' || FINANCIAL_TRANSACTION_BK end"
  AUTHORISATION_PIN_DATE: 'AUG_FINTXN_CHANNEL_AUTHORISATION__AUTHORISATION_PIN_DATE'
  AUTHORISATION_PIN_NUMBER: 'AUG_FINTXN_CHANNEL_AUTHORISATION__AUTHORISATION_PIN_NUMBER'
  AUTHORISATION_PIN_STATUS: 'AUG_FINTXN_CHANNEL_AUTHORISATION__AUTHORISATION_PIN_STATUS'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_stitch_motor__v11_party'
  SOURCE_SYSTEM: '!OPUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
