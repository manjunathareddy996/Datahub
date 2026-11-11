-- automate_dv.stage() for SAT_AUG_POLICY_INSTALMENT_SCHEDULE, read off central view stitch_v15_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v15_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'INSTALMENT_INVOICE_NUMBER'
      - 'INSTALMENT_PERIOD_END_DATE'
      - 'INSTALMENT_NUMBER_CK'
derived_columns:
  POLICY_NK: "case when coalesce(AUG_POLICY_INSTALMENT_SCHEDULE__INSTALMENT_INVOICE_NUMBER, AUG_POLICY_INSTALMENT_SCHEDULE__INSTALMENT_PERIOD_END_DATE) is not null then 'HUB_POLICY|' || POLICY_BK end"
  INSTALMENT_NUMBER_CK: 'AUG_POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER_CK'
  INSTALMENT_INVOICE_NUMBER: 'AUG_POLICY_INSTALMENT_SCHEDULE__INSTALMENT_INVOICE_NUMBER'
  INSTALMENT_PERIOD_END_DATE: 'AUG_POLICY_INSTALMENT_SCHEDULE__INSTALMENT_PERIOD_END_DATE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v15_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
