-- automate_dv.stage() for SAT_AUG_PARTY_GROUP_SCHEME, read off central view stitch_v10_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v10_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AFFINITY_PARTNER_EMPLOYEE_INDICATOR'
      - 'GROUP_HEALTH_USER_TYPE'
derived_columns:
  PARTY_NK: "case when coalesce(AUG_PARTY_GROUP_SCHEME__AFFINITY_PARTNER_EMPLOYEE_INDICATOR, AUG_PARTY_GROUP_SCHEME__GROUP_HEALTH_USER_TYPE) is not null then 'HUB_PARTY|' || PARTY_BK end"
  AFFINITY_PARTNER_EMPLOYEE_INDICATOR: 'AUG_PARTY_GROUP_SCHEME__AFFINITY_PARTNER_EMPLOYEE_INDICATOR'
  GROUP_HEALTH_USER_TYPE: 'AUG_PARTY_GROUP_SCHEME__GROUP_HEALTH_USER_TYPE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v10_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
