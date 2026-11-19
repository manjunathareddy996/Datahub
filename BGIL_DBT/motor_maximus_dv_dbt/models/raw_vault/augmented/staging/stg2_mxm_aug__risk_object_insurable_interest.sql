-- automate_dv.stage() for SAT_MOTOR_AUG_RISK_OBJECT_INSURABLE_INTEREST, read off central view stitch_mxm__v14_risk_object.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v14_risk_object'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'HYPOTHECATION_TYPE'
      - 'INTEREST_HOLDER_INSTITUTION_NAME'
      - 'LEASE_ARRANGEMENT_DETAIL'
      - 'INTEREST_TYPE_CK'
      - 'INTEREST_HOLDER_REFERENCE_CK'
derived_columns:
  RISK_OBJECT_NK: "case when coalesce(AUG_RISK_OBJECT_INSURABLE_INTEREST__HYPOTHECATION_TYPE, AUG_RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_INSTITUTION_NAME, AUG_RISK_OBJECT_INSURABLE_INTEREST__LEASE_ARRANGEMENT_DETAIL) is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  INTEREST_TYPE_CK: 'AUG_RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE_CK'
  INTEREST_HOLDER_REFERENCE_CK: 'AUG_RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_REFERENCE_CK'
  HYPOTHECATION_TYPE: 'AUG_RISK_OBJECT_INSURABLE_INTEREST__HYPOTHECATION_TYPE'
  INTEREST_HOLDER_INSTITUTION_NAME: 'AUG_RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_INSTITUTION_NAME'
  LEASE_ARRANGEMENT_DETAIL: 'AUG_RISK_OBJECT_INSURABLE_INTEREST__LEASE_ARRANGEMENT_DETAIL'
  LOAD_DATETIME: 'RISK_OBJECT_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!stitch_mxm__v14_risk_object'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
