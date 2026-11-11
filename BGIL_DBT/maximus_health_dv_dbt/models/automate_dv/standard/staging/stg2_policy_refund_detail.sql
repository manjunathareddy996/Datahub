-- automate_dv.stage() for SAT_POLICY_REFUND_DETAIL, read off central view stitch_v16_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v16_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'NET_REFUND_AMOUNT'
      - 'REFUND_BASIS'
      - 'REFUND_MODE'
      - 'REFUND_STATUS'
      - 'ACTIVE_SEQUENCE_NUMBER_CK'
derived_columns:
  POLICY_NK: "case when coalesce(POLICY_REFUND_DETAIL__NET_REFUND_AMOUNT, POLICY_REFUND_DETAIL__REFUND_BASIS, POLICY_REFUND_DETAIL__REFUND_MODE, POLICY_REFUND_DETAIL__REFUND_STATUS) is not null then 'HUB_POLICY|' || POLICY_BK end"
  ACTIVE_SEQUENCE_NUMBER_CK: 'POLICY_REFUND_DETAIL__ACTIVE_SEQUENCE_NUMBER_CK'
  NET_REFUND_AMOUNT: 'POLICY_REFUND_DETAIL__NET_REFUND_AMOUNT'
  REFUND_BASIS: 'POLICY_REFUND_DETAIL__REFUND_BASIS'
  REFUND_MODE: 'POLICY_REFUND_DETAIL__REFUND_MODE'
  REFUND_STATUS: 'POLICY_REFUND_DETAIL__REFUND_STATUS'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v16_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
