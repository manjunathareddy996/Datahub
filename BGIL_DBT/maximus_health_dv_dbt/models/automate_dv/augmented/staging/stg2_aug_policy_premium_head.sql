-- automate_dv.stage() for SAT_AUG_POLICY_PREMIUM_HEAD, read off central view stitch_v15_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v15_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PRO_RATA_AMOUNT'
      - 'PREMIUM_HEAD_CODE_CK'
      - 'COVERAGE_REFERENCE_CK'
      - 'SECTION_CK'
      - 'ADJUSTED_INDICATOR_CK'
derived_columns:
  POLICY_NK: "case when AUG_POLICY_PREMIUM_HEAD__PRO_RATA_AMOUNT is not null then 'HUB_POLICY|' || POLICY_BK end"
  PREMIUM_HEAD_CODE_CK: 'AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK'
  COVERAGE_REFERENCE_CK: 'AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK'
  SECTION_CK: 'AUG_POLICY_PREMIUM_HEAD__SECTION_CK'
  ADJUSTED_INDICATOR_CK: 'AUG_POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK'
  PRO_RATA_AMOUNT: 'AUG_POLICY_PREMIUM_HEAD__PRO_RATA_AMOUNT'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v15_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
