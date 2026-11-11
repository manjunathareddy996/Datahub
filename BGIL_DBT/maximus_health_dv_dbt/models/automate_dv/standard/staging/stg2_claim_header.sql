-- automate_dv.stage() for SAT_CLAIM_HEADER, read off central view stitch_v04_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v04_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CASHLESS_INDICATOR'
      - 'CLAIM_CATEGORY'
      - 'CLAIM_REFERENCE_NUMBER'
      - 'CLAIM_REMARKS'
      - 'CLAIM_STATUS'
      - 'CLAIM_TYPE'
      - 'GROSS_INCURRED_AMOUNT'
      - 'INTIMATION_CHANNEL'
      - 'LINE_OF_BUSINESS'
      - 'NOTIFICATION_DATE'
      - 'REGISTRATION_DATE'
      - 'REOPENED_INDICATOR'
derived_columns:
  CLAIM_NK: "case when coalesce(CLAIM_HEADER__CASHLESS_INDICATOR, CLAIM_HEADER__CLAIM_CATEGORY, CLAIM_HEADER__CLAIM_REFERENCE_NUMBER, CLAIM_HEADER__CLAIM_REMARKS, CLAIM_HEADER__CLAIM_STATUS, CLAIM_HEADER__CLAIM_TYPE, CLAIM_HEADER__GROSS_INCURRED_AMOUNT, CLAIM_HEADER__INTIMATION_CHANNEL, CLAIM_HEADER__LINE_OF_BUSINESS, CLAIM_HEADER__NOTIFICATION_DATE, CLAIM_HEADER__REGISTRATION_DATE, CLAIM_HEADER__REOPENED_INDICATOR) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  CASHLESS_INDICATOR: 'CLAIM_HEADER__CASHLESS_INDICATOR'
  CLAIM_CATEGORY: 'CLAIM_HEADER__CLAIM_CATEGORY'
  CLAIM_REFERENCE_NUMBER: 'CLAIM_HEADER__CLAIM_REFERENCE_NUMBER'
  CLAIM_REMARKS: 'CLAIM_HEADER__CLAIM_REMARKS'
  CLAIM_STATUS: 'CLAIM_HEADER__CLAIM_STATUS'
  CLAIM_TYPE: 'CLAIM_HEADER__CLAIM_TYPE'
  GROSS_INCURRED_AMOUNT: 'CLAIM_HEADER__GROSS_INCURRED_AMOUNT'
  INTIMATION_CHANNEL: 'CLAIM_HEADER__INTIMATION_CHANNEL'
  LINE_OF_BUSINESS: 'CLAIM_HEADER__LINE_OF_BUSINESS'
  NOTIFICATION_DATE: 'CLAIM_HEADER__NOTIFICATION_DATE'
  REGISTRATION_DATE: 'CLAIM_HEADER__REGISTRATION_DATE'
  REOPENED_INDICATOR: 'CLAIM_HEADER__REOPENED_INDICATOR'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v04_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
