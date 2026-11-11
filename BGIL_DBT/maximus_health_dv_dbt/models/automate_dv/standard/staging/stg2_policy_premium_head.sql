-- automate_dv.stage() for SAT_POLICY_PREMIUM_HEAD, read off central view stitch_v17_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v17_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BASE_AMOUNT'
      - 'NET_HEAD_PREMIUM'
      - 'PREMIUM_HEAD_CODE_CK'
      - 'COVERAGE_REFERENCE_CK'
      - 'SECTION_CK'
      - 'ADJUSTED_INDICATOR_CK'
derived_columns:
  POLICY_NK: "case when coalesce(POLICY_PREMIUM_HEAD__BASE_AMOUNT, POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM) is not null then 'HUB_POLICY|' || POLICY_BK end"
  PREMIUM_HEAD_CODE_CK: 'POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK'
  COVERAGE_REFERENCE_CK: 'POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK'
  SECTION_CK: 'POLICY_PREMIUM_HEAD__SECTION_CK'
  ADJUSTED_INDICATOR_CK: 'POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK'
  BASE_AMOUNT: 'POLICY_PREMIUM_HEAD__BASE_AMOUNT'
  NET_HEAD_PREMIUM: 'POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v17_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
