-- automate_dv.stage() for SAT_MOTOR_AUG_ORG_UNIT_DEFINITION, read off central view stitch_mxm__v14_risk_object.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v14_risk_object'
hashed_columns:
  ORG_UNIT_HKEY: 'ORG_UNIT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CLUSTER_CODE'
      - 'CLUSTER_NAME'
      - 'OFFICE_NAME_AND_ADDRESS_TEXT'
      - 'OPERATING_UNIT_LABEL'
derived_columns:
  ORG_UNIT_NK: "case when coalesce(AUG_ORG_UNIT_DEFINITION__CLUSTER_CODE, AUG_ORG_UNIT_DEFINITION__CLUSTER_NAME, AUG_ORG_UNIT_DEFINITION__OFFICE_NAME_AND_ADDRESS_TEXT, AUG_ORG_UNIT_DEFINITION__OPERATING_UNIT_LABEL) is not null then 'HUB_ORG_UNIT|' || ORG_UNIT_BK end"
  CLUSTER_CODE: 'AUG_ORG_UNIT_DEFINITION__CLUSTER_CODE'
  CLUSTER_NAME: 'AUG_ORG_UNIT_DEFINITION__CLUSTER_NAME'
  OFFICE_NAME_AND_ADDRESS_TEXT: 'AUG_ORG_UNIT_DEFINITION__OFFICE_NAME_AND_ADDRESS_TEXT'
  OPERATING_UNIT_LABEL: 'AUG_ORG_UNIT_DEFINITION__OPERATING_UNIT_LABEL'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v14_risk_object'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
