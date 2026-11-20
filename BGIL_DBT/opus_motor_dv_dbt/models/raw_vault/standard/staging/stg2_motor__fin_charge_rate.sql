-- automate_dv.stage() for SAT_FIN_CHARGE_RATE, read off central view stitch_motor__v11_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v11_party'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CHARGE_RATE'
      - 'CHARGE_TYPE_CK'
derived_columns:
  FINANCIAL_TRANSACTION_NK: "case when FIN_CHARGE_RATE__CHARGE_RATE is not null then 'HUB_FINANCIAL_TRANSACTION|' || FINANCIAL_TRANSACTION_BK end"
  CHARGE_TYPE_CK: 'FIN_CHARGE_RATE__CHARGE_TYPE_CK'
  CHARGE_RATE: 'FIN_CHARGE_RATE__CHARGE_RATE'
  LOAD_DATETIME: 'FINANCIAL_TRANSACTION_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!OPUS_stitch_motor__v11_party'
  SOURCE_SYSTEM: '!OPUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
