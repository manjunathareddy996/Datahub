-- automate_dv.stage() for SAT_AUG_ORG_UNIT_DEFINITION, read off central view stitch_v14_org_unit.
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
      - 'ACCOUNTING_CATEGORY_CODE'
      - 'NEAREST_CONTROLLING_ORG_UNIT_REFERENCE'
      - 'ORG_UNIT_STATUS_REASON'
      - 'REGISTRATION_INDICATOR'
      - 'SOURCE_RECORD_DATE'
derived_columns:
  ORG_UNIT_NK: "case when coalesce(AUG_ORG_UNIT_DEFINITION__ACCOUNTING_CATEGORY_CODE, AUG_ORG_UNIT_DEFINITION__NEAREST_CONTROLLING_ORG_UNIT_REFERENCE, AUG_ORG_UNIT_DEFINITION__ORG_UNIT_STATUS_REASON, AUG_ORG_UNIT_DEFINITION__REGISTRATION_INDICATOR, AUG_ORG_UNIT_DEFINITION__SOURCE_RECORD_DATE) is not null then 'HUB_ORG_UNIT|' || ORG_UNIT_BK end"
  ACCOUNTING_CATEGORY_CODE: 'AUG_ORG_UNIT_DEFINITION__ACCOUNTING_CATEGORY_CODE'
  NEAREST_CONTROLLING_ORG_UNIT_REFERENCE: 'AUG_ORG_UNIT_DEFINITION__NEAREST_CONTROLLING_ORG_UNIT_REFERENCE'
  ORG_UNIT_STATUS_REASON: 'AUG_ORG_UNIT_DEFINITION__ORG_UNIT_STATUS_REASON'
  REGISTRATION_INDICATOR: 'AUG_ORG_UNIT_DEFINITION__REGISTRATION_INDICATOR'
  SOURCE_RECORD_DATE: 'AUG_ORG_UNIT_DEFINITION__SOURCE_RECORD_DATE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v14_org_unit'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
