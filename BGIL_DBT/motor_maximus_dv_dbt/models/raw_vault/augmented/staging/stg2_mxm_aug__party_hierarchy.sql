-- automate_dv.stage() for SAT_MOTOR_AUG_PARTY_HIERARCHY, read off central view stitch_mxm__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v09_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BRANCH_REFERENCE'
      - 'MULTI_OFFICE_BUSINESS_INDICATOR'
      - 'PRIMARY_BRANCH_REFERENCE'
      - 'SECONDARY_BRANCH_REFERENCE'
      - 'TRANSFER_CASE_REFERENCE'
      - 'TRANSFER_INDICATOR'
derived_columns:
  PARTY_NK: "case when coalesce(AUG_PARTY_HIERARCHY__BRANCH_REFERENCE, AUG_PARTY_HIERARCHY__MULTI_OFFICE_BUSINESS_INDICATOR, AUG_PARTY_HIERARCHY__PRIMARY_BRANCH_REFERENCE, AUG_PARTY_HIERARCHY__SECONDARY_BRANCH_REFERENCE, AUG_PARTY_HIERARCHY__TRANSFER_CASE_REFERENCE, AUG_PARTY_HIERARCHY__TRANSFER_INDICATOR) is not null then 'HUB_PARTY|' || PARTY_BK end"
  BRANCH_REFERENCE: 'AUG_PARTY_HIERARCHY__BRANCH_REFERENCE'
  MULTI_OFFICE_BUSINESS_INDICATOR: 'AUG_PARTY_HIERARCHY__MULTI_OFFICE_BUSINESS_INDICATOR'
  PRIMARY_BRANCH_REFERENCE: 'AUG_PARTY_HIERARCHY__PRIMARY_BRANCH_REFERENCE'
  SECONDARY_BRANCH_REFERENCE: 'AUG_PARTY_HIERARCHY__SECONDARY_BRANCH_REFERENCE'
  TRANSFER_CASE_REFERENCE: 'AUG_PARTY_HIERARCHY__TRANSFER_CASE_REFERENCE'
  TRANSFER_INDICATOR: 'AUG_PARTY_HIERARCHY__TRANSFER_INDICATOR'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v09_party'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
