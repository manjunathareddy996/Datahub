-- automate_dv.stage() for SAT_PARTY_ORGANISATION_PROFILE, read off central view stitch_v15_party.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v15_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'GROUP_NAME'
      - 'LEGAL_CONSTITUTION_CODE'
      - 'MSME_CATEGORY'
      - 'MSME_INDICATOR'
derived_columns:
  PARTY_NK: "case when coalesce(PARTY_ORGANISATION_PROFILE__GROUP_NAME, PARTY_ORGANISATION_PROFILE__LEGAL_CONSTITUTION_CODE, PARTY_ORGANISATION_PROFILE__MSME_CATEGORY, PARTY_ORGANISATION_PROFILE__MSME_INDICATOR) is not null then 'HUB_PARTY|' || PARTY_BK end"
  GROUP_NAME: 'PARTY_ORGANISATION_PROFILE__GROUP_NAME'
  LEGAL_CONSTITUTION_CODE: 'PARTY_ORGANISATION_PROFILE__LEGAL_CONSTITUTION_CODE'
  MSME_CATEGORY: 'PARTY_ORGANISATION_PROFILE__MSME_CATEGORY'
  MSME_INDICATOR: 'PARTY_ORGANISATION_PROFILE__MSME_INDICATOR'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v15_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
