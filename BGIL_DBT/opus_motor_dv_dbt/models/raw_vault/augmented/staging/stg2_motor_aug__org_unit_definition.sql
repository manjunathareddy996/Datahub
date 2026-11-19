-- automate_dv.stage() for SAT_MOTOR_AUG_ORG_UNIT_DEFINITION, read off central view stitch_motor__v08_org_unit.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v08_org_unit'
hashed_columns:
  ORG_UNIT_HKEY: 'ORG_UNIT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BRANCH_GROUP_EFFECTIVE_DATE'
      - 'DEPARTMENT_CODE'
      - 'SECONDARY_DEPARTMENT_CODE'
derived_columns:
  ORG_UNIT_NK: "case when coalesce(AUG_ORG_UNIT_DEFINITION__BRANCH_GROUP_EFFECTIVE_DATE, AUG_ORG_UNIT_DEFINITION__DEPARTMENT_CODE, AUG_ORG_UNIT_DEFINITION__SECONDARY_DEPARTMENT_CODE) is not null then 'HUB_ORG_UNIT|' || ORG_UNIT_BK end"
  BRANCH_GROUP_EFFECTIVE_DATE: 'AUG_ORG_UNIT_DEFINITION__BRANCH_GROUP_EFFECTIVE_DATE'
  DEPARTMENT_CODE: 'AUG_ORG_UNIT_DEFINITION__DEPARTMENT_CODE'
  SECONDARY_DEPARTMENT_CODE: 'AUG_ORG_UNIT_DEFINITION__SECONDARY_DEPARTMENT_CODE'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_MOTOR_V08_ORG_UNIT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
