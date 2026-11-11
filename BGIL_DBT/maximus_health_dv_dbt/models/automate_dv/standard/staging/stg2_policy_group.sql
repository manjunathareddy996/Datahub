-- automate_dv.stage() for SAT_POLICY_GROUP, read off central view stitch_v15_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v15_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'EMPLOYER_CONTRIBUTION_PERCENTAGE'
      - 'GROUP_SIZE'
      - 'GROUP_TYPE'
      - 'MASTER_POLICY_NUMBER'
      - 'MEMBER_ENROLMENT_BASIS'
derived_columns:
  POLICY_NK: "case when coalesce(POLICY_GROUP__EMPLOYER_CONTRIBUTION_PERCENTAGE, POLICY_GROUP__GROUP_SIZE, POLICY_GROUP__GROUP_TYPE, POLICY_GROUP__MASTER_POLICY_NUMBER, POLICY_GROUP__MEMBER_ENROLMENT_BASIS) is not null then 'HUB_POLICY|' || POLICY_BK end"
  EMPLOYER_CONTRIBUTION_PERCENTAGE: 'POLICY_GROUP__EMPLOYER_CONTRIBUTION_PERCENTAGE'
  GROUP_SIZE: 'POLICY_GROUP__GROUP_SIZE'
  GROUP_TYPE: 'POLICY_GROUP__GROUP_TYPE'
  MASTER_POLICY_NUMBER: 'POLICY_GROUP__MASTER_POLICY_NUMBER'
  MEMBER_ENROLMENT_BASIS: 'POLICY_GROUP__MEMBER_ENROLMENT_BASIS'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v15_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
