-- automate_dv.stage() for SAT_POLICY_INSTALMENT_SCHEDULE, read off central view stitch_v15_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v15_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AUTO_DEBIT_INDICATOR'
      - 'DUE_DATE'
      - 'INSTALMENT_AMOUNT'
      - 'INSTALMENT_STATUS'
      - 'OUTSTANDING_AFTER_INSTALMENT'
      - 'PAID_DATE'
      - 'INSTALMENT_NUMBER_CK'
derived_columns:
  POLICY_NK: "case when coalesce(POLICY_INSTALMENT_SCHEDULE__AUTO_DEBIT_INDICATOR, POLICY_INSTALMENT_SCHEDULE__DUE_DATE, POLICY_INSTALMENT_SCHEDULE__INSTALMENT_AMOUNT, POLICY_INSTALMENT_SCHEDULE__INSTALMENT_STATUS, POLICY_INSTALMENT_SCHEDULE__OUTSTANDING_AFTER_INSTALMENT, POLICY_INSTALMENT_SCHEDULE__PAID_DATE) is not null then 'HUB_POLICY|' || POLICY_BK end"
  INSTALMENT_NUMBER_CK: 'POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER_CK'
  AUTO_DEBIT_INDICATOR: 'POLICY_INSTALMENT_SCHEDULE__AUTO_DEBIT_INDICATOR'
  DUE_DATE: 'POLICY_INSTALMENT_SCHEDULE__DUE_DATE'
  INSTALMENT_AMOUNT: 'POLICY_INSTALMENT_SCHEDULE__INSTALMENT_AMOUNT'
  INSTALMENT_STATUS: 'POLICY_INSTALMENT_SCHEDULE__INSTALMENT_STATUS'
  OUTSTANDING_AFTER_INSTALMENT: 'POLICY_INSTALMENT_SCHEDULE__OUTSTANDING_AFTER_INSTALMENT'
  PAID_DATE: 'POLICY_INSTALMENT_SCHEDULE__PAID_DATE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v15_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
