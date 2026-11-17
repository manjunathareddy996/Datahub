-- automate_dv.stage() for SAT_AUG_POLICY_PREMIUM_SETTLEMENT, read off central view stitch_motor__v14_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v14_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ACCOUNTING_BATCH_REFERENCE'
      - 'ACCOUNTING_PASS_INDICATOR'
      - 'ACCOUNTING_POSTING_DATE'
      - 'SETTLEMENT_LINE_SEQUENCE_CK'
      - 'SETTLEMENT_LINE_REFERENCE_CK'
derived_columns:
  POLICY_NK: "case when coalesce(AUG_POLICY_PREMIUM_SETTLEMENT__ACCOUNTING_BATCH_REFERENCE, AUG_POLICY_PREMIUM_SETTLEMENT__ACCOUNTING_PASS_INDICATOR, AUG_POLICY_PREMIUM_SETTLEMENT__ACCOUNTING_POSTING_DATE) is not null then 'HUB_POLICY|' || POLICY_BK end"
  SETTLEMENT_LINE_SEQUENCE_CK: 'AUG_POLICY_PREMIUM_SETTLEMENT__SETTLEMENT_LINE_SEQUENCE_CK'
  SETTLEMENT_LINE_REFERENCE_CK: 'AUG_POLICY_PREMIUM_SETTLEMENT__SETTLEMENT_LINE_REFERENCE_CK'
  ACCOUNTING_BATCH_REFERENCE: 'AUG_POLICY_PREMIUM_SETTLEMENT__ACCOUNTING_BATCH_REFERENCE'
  ACCOUNTING_PASS_INDICATOR: 'AUG_POLICY_PREMIUM_SETTLEMENT__ACCOUNTING_PASS_INDICATOR'
  ACCOUNTING_POSTING_DATE: 'AUG_POLICY_PREMIUM_SETTLEMENT__ACCOUNTING_POSTING_DATE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_motor__v14_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
