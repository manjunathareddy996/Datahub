-- automate_dv.stage() for SAT_AUG_PARTY_EMPLOYMENT, read off central view stitch_v14_org_unit.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v14_org_unit'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'EMPLOYEE_NUMBER'
      - 'MONTHLY_SALARY_AMOUNT'
derived_columns:
  PARTY_NK: "case when coalesce(AUG_PARTY_EMPLOYMENT__EMPLOYEE_NUMBER, AUG_PARTY_EMPLOYMENT__MONTHLY_SALARY_AMOUNT) is not null then 'HUB_PARTY|' || PARTY_BK end"
  EMPLOYEE_NUMBER: 'AUG_PARTY_EMPLOYMENT__EMPLOYEE_NUMBER'
  MONTHLY_SALARY_AMOUNT: 'AUG_PARTY_EMPLOYMENT__MONTHLY_SALARY_AMOUNT'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v14_org_unit'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
