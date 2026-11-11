-- automate_dv.stage() for SAT_ORG_UNIT_DEFINITION, read off central view stitch_v14_org_unit.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v14_org_unit'
hashed_columns:
  ORG_UNIT_HKEY: 'ORG_UNIT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BRANCH_TYPE'
      - 'HEAD_REFERENCE'
      - 'ORG_UNIT_CODE'
      - 'ORG_UNIT_NAME'
      - 'ORG_UNIT_STATUS'
      - 'PARENT_ORG_UNIT_REFERENCE'
      - 'ZONE_NAME'
derived_columns:
  ORG_UNIT_NK: "case when coalesce(ORG_UNIT_DEFINITION__BRANCH_TYPE, ORG_UNIT_DEFINITION__HEAD_REFERENCE, ORG_UNIT_DEFINITION__ORG_UNIT_CODE, ORG_UNIT_DEFINITION__ORG_UNIT_NAME, ORG_UNIT_DEFINITION__ORG_UNIT_STATUS, ORG_UNIT_DEFINITION__PARENT_ORG_UNIT_REFERENCE, ORG_UNIT_DEFINITION__ZONE_NAME) is not null then 'HUB_ORG_UNIT|' || ORG_UNIT_BK end"
  BRANCH_TYPE: 'ORG_UNIT_DEFINITION__BRANCH_TYPE'
  HEAD_REFERENCE: 'ORG_UNIT_DEFINITION__HEAD_REFERENCE'
  ORG_UNIT_CODE: 'ORG_UNIT_DEFINITION__ORG_UNIT_CODE'
  ORG_UNIT_NAME: 'ORG_UNIT_DEFINITION__ORG_UNIT_NAME'
  ORG_UNIT_STATUS: 'ORG_UNIT_DEFINITION__ORG_UNIT_STATUS'
  PARENT_ORG_UNIT_REFERENCE: 'ORG_UNIT_DEFINITION__PARENT_ORG_UNIT_REFERENCE'
  ZONE_NAME: 'ORG_UNIT_DEFINITION__ZONE_NAME'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v14_org_unit'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
