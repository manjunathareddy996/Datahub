-- automate_dv.stage() for SAT_MOTOR_AUG_POLICY_DELIVERY, read off central view stitch_motor__v12_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v12_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COURIER_VENDOR_NAME'
      - 'DISPATCH_TIME'
      - 'DISPATCH_TRANSACTION_DATE'
derived_columns:
  POLICY_NK: "case when coalesce(AUG_POLICY_DELIVERY__COURIER_VENDOR_NAME, AUG_POLICY_DELIVERY__DISPATCH_TIME, AUG_POLICY_DELIVERY__DISPATCH_TRANSACTION_DATE) is not null then 'HUB_POLICY|' || POLICY_BK end"
  COURIER_VENDOR_NAME: 'AUG_POLICY_DELIVERY__COURIER_VENDOR_NAME'
  DISPATCH_TIME: 'AUG_POLICY_DELIVERY__DISPATCH_TIME'
  DISPATCH_TRANSACTION_DATE: 'AUG_POLICY_DELIVERY__DISPATCH_TRANSACTION_DATE'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_stitch_motor__v12_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
