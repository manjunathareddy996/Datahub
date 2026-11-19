-- automate_dv.stage() for SAT_PARTY_HIERARCHY, read off central view stitch_mxm__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v09_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'HIERARCHY_LEVEL'
      - 'REPORTING_PARENT_REFERENCE'
      - 'TERRITORY_CODE'
derived_columns:
  PARTY_NK: "case when coalesce(PARTY_HIERARCHY__HIERARCHY_LEVEL, PARTY_HIERARCHY__REPORTING_PARENT_REFERENCE, PARTY_HIERARCHY__TERRITORY_CODE) is not null then 'HUB_PARTY|' || PARTY_BK end"
  HIERARCHY_LEVEL: 'PARTY_HIERARCHY__HIERARCHY_LEVEL'
  REPORTING_PARENT_REFERENCE: 'PARTY_HIERARCHY__REPORTING_PARENT_REFERENCE'
  TERRITORY_CODE: 'PARTY_HIERARCHY__TERRITORY_CODE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v09_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
