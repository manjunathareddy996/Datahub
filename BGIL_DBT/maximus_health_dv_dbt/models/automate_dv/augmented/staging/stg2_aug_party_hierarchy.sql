-- automate_dv.stage() for SAT_AUG_PARTY_HIERARCHY, read off central view stitch_v10_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v10_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'RELATIONSHIP_ASSOCIATE_EMPLOYEE_CODE'
      - 'TRANSFER_CASE_REFERENCE'
      - 'TRANSFER_INDICATOR'
derived_columns:
  PARTY_NK: "case when coalesce(AUG_PARTY_HIERARCHY__RELATIONSHIP_ASSOCIATE_EMPLOYEE_CODE, AUG_PARTY_HIERARCHY__TRANSFER_CASE_REFERENCE, AUG_PARTY_HIERARCHY__TRANSFER_INDICATOR) is not null then 'HUB_PARTY|' || PARTY_BK end"
  RELATIONSHIP_ASSOCIATE_EMPLOYEE_CODE: 'AUG_PARTY_HIERARCHY__RELATIONSHIP_ASSOCIATE_EMPLOYEE_CODE'
  TRANSFER_CASE_REFERENCE: 'AUG_PARTY_HIERARCHY__TRANSFER_CASE_REFERENCE'
  TRANSFER_INDICATOR: 'AUG_PARTY_HIERARCHY__TRANSFER_INDICATOR'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v10_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
