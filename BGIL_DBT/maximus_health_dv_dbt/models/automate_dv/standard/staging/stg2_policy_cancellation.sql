-- automate_dv.stage() for SAT_POLICY_CANCELLATION, read off central view stitch_v16_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v16_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CANCELLATION_DATE'
      - 'CANCELLATION_EFFECTIVE_DATE'
      - 'CANCELLATION_REASON'
      - 'CANCELLATION_TYPE'
      - 'REFUND_AMOUNT'
derived_columns:
  POLICY_NK: "case when coalesce(POLICY_CANCELLATION__CANCELLATION_DATE, POLICY_CANCELLATION__CANCELLATION_EFFECTIVE_DATE, POLICY_CANCELLATION__CANCELLATION_REASON, POLICY_CANCELLATION__CANCELLATION_TYPE, POLICY_CANCELLATION__REFUND_AMOUNT) is not null then 'HUB_POLICY|' || POLICY_BK end"
  CANCELLATION_DATE: 'POLICY_CANCELLATION__CANCELLATION_DATE'
  CANCELLATION_EFFECTIVE_DATE: 'POLICY_CANCELLATION__CANCELLATION_EFFECTIVE_DATE'
  CANCELLATION_REASON: 'POLICY_CANCELLATION__CANCELLATION_REASON'
  CANCELLATION_TYPE: 'POLICY_CANCELLATION__CANCELLATION_TYPE'
  REFUND_AMOUNT: 'POLICY_CANCELLATION__REFUND_AMOUNT'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v16_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
