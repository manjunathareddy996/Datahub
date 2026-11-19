-- automate_dv.stage() for SAT_FINTXN_HEADER, read off central view stitch_motor__v11_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v11_party'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'NARRATION'
      - 'ORG_UNIT_CODE'
      - 'ORIGINATING_SYSTEM_REFERENCE'
      - 'SOURCE_REFERENCE_NUMBER'
      - 'TRANSACTION_CHANNEL'
      - 'TRANSACTION_DATE'
      - 'TRANSACTION_SUB_TYPE'
      - 'TRANSACTION_TYPE'
derived_columns:
  FINANCIAL_TRANSACTION_NK: "case when coalesce(FINTXN_HEADER__NARRATION, FINTXN_HEADER__ORG_UNIT_CODE, FINTXN_HEADER__ORIGINATING_SYSTEM_REFERENCE, FINTXN_HEADER__SOURCE_REFERENCE_NUMBER, FINTXN_HEADER__TRANSACTION_CHANNEL, FINTXN_HEADER__TRANSACTION_DATE, FINTXN_HEADER__TRANSACTION_SUB_TYPE, FINTXN_HEADER__TRANSACTION_TYPE) is not null then 'HUB_FINANCIAL_TRANSACTION|' || FINANCIAL_TRANSACTION_BK end"
  NARRATION: 'FINTXN_HEADER__NARRATION'
  ORG_UNIT_CODE: 'FINTXN_HEADER__ORG_UNIT_CODE'
  ORIGINATING_SYSTEM_REFERENCE: 'FINTXN_HEADER__ORIGINATING_SYSTEM_REFERENCE'
  SOURCE_REFERENCE_NUMBER: 'FINTXN_HEADER__SOURCE_REFERENCE_NUMBER'
  TRANSACTION_CHANNEL: 'FINTXN_HEADER__TRANSACTION_CHANNEL'
  TRANSACTION_DATE: 'FINTXN_HEADER__TRANSACTION_DATE'
  TRANSACTION_SUB_TYPE: 'FINTXN_HEADER__TRANSACTION_SUB_TYPE'
  TRANSACTION_TYPE: 'FINTXN_HEADER__TRANSACTION_TYPE'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_stitch_motor__v11_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
