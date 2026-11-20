-- automate_dv.stage() for SAT_LNK_ROLE_EMPLOYEE, read off central view stitch_mxm__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v09_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DEPARTMENT'
      - 'EMPLOYEE_CODE'
      - 'FUNCTION'
      - 'ROLE_TYPE_CK'
derived_columns:
  PARTY_NK: "case when coalesce(LNK_ROLE_EMPLOYEE__DEPARTMENT, LNK_ROLE_EMPLOYEE__EMPLOYEE_CODE, LNK_ROLE_EMPLOYEE__FUNCTION) is not null then 'HUB_PARTY|' || PARTY_BK end"
  ROLE_TYPE_CK: 'LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK'
  DEPARTMENT: 'LNK_ROLE_EMPLOYEE__DEPARTMENT'
  EMPLOYEE_CODE: 'LNK_ROLE_EMPLOYEE__EMPLOYEE_CODE'
  FUNCTION: 'LNK_ROLE_EMPLOYEE__FUNCTION'
  LOAD_DATETIME: 'PARTY_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v09_party'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
