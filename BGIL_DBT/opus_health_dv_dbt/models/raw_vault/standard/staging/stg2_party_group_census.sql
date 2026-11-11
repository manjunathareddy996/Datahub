-- automate_dv.stage() for SAT_PARTY_GROUP_CENSUS, read off central view stitch_v09_claim.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v09_claim'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ACTIVE_INDICATOR'
      - 'DATE_OF_JOINING'
      - 'DESIGNATION_BAND'
      - 'EMPLOYEE_ID'
      - 'LOCATION_REFERENCE'
      - 'MEMBER_NAME'
      - 'MEMBER_REFERENCE_CK'
derived_columns:
  PARTY_NK: "case when coalesce(PARTY_GROUP_CENSUS__ACTIVE_INDICATOR, PARTY_GROUP_CENSUS__DATE_OF_JOINING, PARTY_GROUP_CENSUS__DESIGNATION_BAND, PARTY_GROUP_CENSUS__EMPLOYEE_ID, PARTY_GROUP_CENSUS__LOCATION_REFERENCE, PARTY_GROUP_CENSUS__MEMBER_NAME) is not null then 'HUB_PARTY|' || PARTY_BK end"
  MEMBER_REFERENCE_CK: 'PARTY_GROUP_CENSUS__MEMBER_REFERENCE_CK'
  ACTIVE_INDICATOR: 'PARTY_GROUP_CENSUS__ACTIVE_INDICATOR'
  DATE_OF_JOINING: 'PARTY_GROUP_CENSUS__DATE_OF_JOINING'
  DESIGNATION_BAND: 'PARTY_GROUP_CENSUS__DESIGNATION_BAND'
  EMPLOYEE_ID: 'PARTY_GROUP_CENSUS__EMPLOYEE_ID'
  LOCATION_REFERENCE: 'PARTY_GROUP_CENSUS__LOCATION_REFERENCE'
  MEMBER_NAME: 'PARTY_GROUP_CENSUS__MEMBER_NAME'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v09_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
