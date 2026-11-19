-- automate_dv.stage() for SAT_POLICY_RENEWAL, read off central view stitch_motor__v14_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v14_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CANCELLED_POLICY_INDICATOR'
      - 'PRECEDING_POLICY_REFERENCE'
      - 'RENEWAL_BLOCK_REASON'
      - 'RENEWAL_DISCOUNT'
      - 'RENEWAL_PREMIUM'
      - 'RENEWAL_STATUS'
derived_columns:
  POLICY_NK: "case when coalesce(POLICY_RENEWAL__CANCELLED_POLICY_INDICATOR, POLICY_RENEWAL__PRECEDING_POLICY_REFERENCE, POLICY_RENEWAL__RENEWAL_BLOCK_REASON, POLICY_RENEWAL__RENEWAL_DISCOUNT, POLICY_RENEWAL__RENEWAL_PREMIUM, POLICY_RENEWAL__RENEWAL_STATUS) is not null then 'HUB_POLICY|' || POLICY_BK end"
  CANCELLED_POLICY_INDICATOR: 'POLICY_RENEWAL__CANCELLED_POLICY_INDICATOR'
  PRECEDING_POLICY_REFERENCE: 'POLICY_RENEWAL__PRECEDING_POLICY_REFERENCE'
  RENEWAL_BLOCK_REASON: 'POLICY_RENEWAL__RENEWAL_BLOCK_REASON'
  RENEWAL_DISCOUNT: 'POLICY_RENEWAL__RENEWAL_DISCOUNT'
  RENEWAL_PREMIUM: 'POLICY_RENEWAL__RENEWAL_PREMIUM'
  RENEWAL_STATUS: 'POLICY_RENEWAL__RENEWAL_STATUS'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_MOTOR_V14_POLICY'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
