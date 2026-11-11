-- automate_dv.stage() for SAT_CLAIM_HEADER, read off central view stitch_v07_claim.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v07_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CLAIM_CATEGORY'
      - 'CLAIM_REFERENCE_NUMBER'
      - 'CLAIM_REMARKS'
      - 'CLAIM_STATUS'
      - 'CLAIM_SUB_STATUS'
      - 'CLAIM_TYPE'
      - 'CLOSED_DATE'
      - 'GROSS_INCURRED_AMOUNT'
      - 'LOSS_DATE'
      - 'NET_INCURRED_AMOUNT'
      - 'NOTIFICATION_DATE'
      - 'POLICY_REFERENCE'
      - 'REGISTRATION_DATE'
derived_columns:
  CLAIM_NK: "case when coalesce(CLAIM_HEADER__CLAIM_CATEGORY, CLAIM_HEADER__CLAIM_REFERENCE_NUMBER, CLAIM_HEADER__CLAIM_REMARKS, CLAIM_HEADER__CLAIM_STATUS, CLAIM_HEADER__CLAIM_SUB_STATUS, CLAIM_HEADER__CLAIM_TYPE, CLAIM_HEADER__CLOSED_DATE, CLAIM_HEADER__GROSS_INCURRED_AMOUNT, CLAIM_HEADER__LOSS_DATE, CLAIM_HEADER__NET_INCURRED_AMOUNT, CLAIM_HEADER__NOTIFICATION_DATE, CLAIM_HEADER__POLICY_REFERENCE, CLAIM_HEADER__REGISTRATION_DATE) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  CLAIM_CATEGORY: 'CLAIM_HEADER__CLAIM_CATEGORY'
  CLAIM_REFERENCE_NUMBER: 'CLAIM_HEADER__CLAIM_REFERENCE_NUMBER'
  CLAIM_REMARKS: 'CLAIM_HEADER__CLAIM_REMARKS'
  CLAIM_STATUS: 'CLAIM_HEADER__CLAIM_STATUS'
  CLAIM_SUB_STATUS: 'CLAIM_HEADER__CLAIM_SUB_STATUS'
  CLAIM_TYPE: 'CLAIM_HEADER__CLAIM_TYPE'
  CLOSED_DATE: 'CLAIM_HEADER__CLOSED_DATE'
  GROSS_INCURRED_AMOUNT: 'CLAIM_HEADER__GROSS_INCURRED_AMOUNT'
  LOSS_DATE: 'CLAIM_HEADER__LOSS_DATE'
  NET_INCURRED_AMOUNT: 'CLAIM_HEADER__NET_INCURRED_AMOUNT'
  NOTIFICATION_DATE: 'CLAIM_HEADER__NOTIFICATION_DATE'
  POLICY_REFERENCE: 'CLAIM_HEADER__POLICY_REFERENCE'
  REGISTRATION_DATE: 'CLAIM_HEADER__REGISTRATION_DATE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v07_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
