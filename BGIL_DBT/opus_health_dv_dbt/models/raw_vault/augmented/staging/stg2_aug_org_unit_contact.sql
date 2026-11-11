-- automate_dv.stage() for SAT_AUG_ORG_UNIT_CONTACT, read off central view stitch_v14_org_unit.
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
      - 'EMAIL_ADDRESS'
      - 'FAX_NUMBER'
      - 'LANDLINE_NUMBER'
derived_columns:
  ORG_UNIT_NK: "case when coalesce(AUG_ORG_UNIT_CONTACT__EMAIL_ADDRESS, AUG_ORG_UNIT_CONTACT__FAX_NUMBER, AUG_ORG_UNIT_CONTACT__LANDLINE_NUMBER) is not null then 'HUB_ORG_UNIT|' || ORG_UNIT_BK end"
  EMAIL_ADDRESS: 'AUG_ORG_UNIT_CONTACT__EMAIL_ADDRESS'
  FAX_NUMBER: 'AUG_ORG_UNIT_CONTACT__FAX_NUMBER'
  LANDLINE_NUMBER: 'AUG_ORG_UNIT_CONTACT__LANDLINE_NUMBER'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v14_org_unit'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
