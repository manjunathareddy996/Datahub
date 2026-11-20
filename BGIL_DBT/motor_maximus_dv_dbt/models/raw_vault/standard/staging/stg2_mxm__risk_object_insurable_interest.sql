-- automate_dv.stage() for SAT_RISK_OBJECT_INSURABLE_INTEREST, read off central view stitch_mxm__v14_risk_object.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v14_risk_object'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'FINANCIER_NAME'
      - 'HYPOTHECATION_INDICATOR'
      - 'INTEREST_TYPE'
      - 'LEASE_INDICATOR'
      - 'INTEREST_TYPE_CK'
      - 'INTEREST_HOLDER_REFERENCE_CK'
derived_columns:
  RISK_OBJECT_NK: "case when coalesce(RISK_OBJECT_INSURABLE_INTEREST__FINANCIER_NAME, RISK_OBJECT_INSURABLE_INTEREST__HYPOTHECATION_INDICATOR, RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE, RISK_OBJECT_INSURABLE_INTEREST__LEASE_INDICATOR) is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  INTEREST_TYPE_CK: 'RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE_CK'
  INTEREST_HOLDER_REFERENCE_CK: 'RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_REFERENCE_CK'
  FINANCIER_NAME: 'RISK_OBJECT_INSURABLE_INTEREST__FINANCIER_NAME'
  HYPOTHECATION_INDICATOR: 'RISK_OBJECT_INSURABLE_INTEREST__HYPOTHECATION_INDICATOR'
  INTEREST_TYPE: 'RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE'
  LEASE_INDICATOR: 'RISK_OBJECT_INSURABLE_INTEREST__LEASE_INDICATOR'
  LOAD_DATETIME: 'RISK_OBJECT_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v14_risk_object'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
