-- automate_dv.stage() for SAT_COVERAGE_MEMBER_BENEFIT, read off central view stitch_v17_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v17_policy'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BENEFIT_CODE'
      - 'BENEFIT_NAME'
      - 'BENEFIT_CODE_CK'
derived_columns:
  COVERAGE_NK: "case when coalesce(COVERAGE_MEMBER_BENEFIT__BENEFIT_CODE, COVERAGE_MEMBER_BENEFIT__BENEFIT_NAME) is not null then 'HUB_COVERAGE|' || COVERAGE_BK end"
  BENEFIT_CODE_CK: 'COVERAGE_MEMBER_BENEFIT__BENEFIT_CODE_CK'
  BENEFIT_CODE: 'COVERAGE_MEMBER_BENEFIT__BENEFIT_CODE'
  BENEFIT_NAME: 'COVERAGE_MEMBER_BENEFIT__BENEFIT_NAME'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v17_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
