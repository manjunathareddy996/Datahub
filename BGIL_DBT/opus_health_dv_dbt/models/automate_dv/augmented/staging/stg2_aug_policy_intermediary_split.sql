-- automate_dv.stage() for SAT_AUG_POLICY_INTERMEDIARY_SPLIT, read off central view stitch_v23_policy.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v23_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BROKERAGE_AMOUNT'
      - 'DEALER_CODE'
      - 'SERVICE_CHARGE_AMOUNT'
      - 'SERVICE_CHARGE_RATE'
derived_columns:
  POLICY_NK: "case when coalesce(AUG_POLICY_INTERMEDIARY_SPLIT__BROKERAGE_AMOUNT, AUG_POLICY_INTERMEDIARY_SPLIT__DEALER_CODE, AUG_POLICY_INTERMEDIARY_SPLIT__SERVICE_CHARGE_AMOUNT, AUG_POLICY_INTERMEDIARY_SPLIT__SERVICE_CHARGE_RATE) is not null then 'HUB_POLICY|' || POLICY_BK end"
  BROKERAGE_AMOUNT: 'AUG_POLICY_INTERMEDIARY_SPLIT__BROKERAGE_AMOUNT'
  DEALER_CODE: 'AUG_POLICY_INTERMEDIARY_SPLIT__DEALER_CODE'
  SERVICE_CHARGE_AMOUNT: 'AUG_POLICY_INTERMEDIARY_SPLIT__SERVICE_CHARGE_AMOUNT'
  SERVICE_CHARGE_RATE: 'AUG_POLICY_INTERMEDIARY_SPLIT__SERVICE_CHARGE_RATE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v23_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
