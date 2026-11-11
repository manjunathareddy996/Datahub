-- automate_dv.stage() for SAT_AUG_PARTY_EMPLOYMENT, read off central view stitch_v10_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v10_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'EMPLOYER_DETAIL_DESCRIPTION'
      - 'OTHER_OCCUPATION'
      - 'PRIMARY_PROFESSION'
      - 'TOTAL_YEARS_OF_EXPERIENCE'
      - 'USED_CAR_DEALER_OCCUPATION_INDICATOR'
derived_columns:
  PARTY_NK: "case when coalesce(AUG_PARTY_EMPLOYMENT__EMPLOYER_DETAIL_DESCRIPTION, AUG_PARTY_EMPLOYMENT__OTHER_OCCUPATION, AUG_PARTY_EMPLOYMENT__PRIMARY_PROFESSION, AUG_PARTY_EMPLOYMENT__TOTAL_YEARS_OF_EXPERIENCE, AUG_PARTY_EMPLOYMENT__USED_CAR_DEALER_OCCUPATION_INDICATOR) is not null then 'HUB_PARTY|' || PARTY_BK end"
  EMPLOYER_DETAIL_DESCRIPTION: 'AUG_PARTY_EMPLOYMENT__EMPLOYER_DETAIL_DESCRIPTION'
  OTHER_OCCUPATION: 'AUG_PARTY_EMPLOYMENT__OTHER_OCCUPATION'
  PRIMARY_PROFESSION: 'AUG_PARTY_EMPLOYMENT__PRIMARY_PROFESSION'
  TOTAL_YEARS_OF_EXPERIENCE: 'AUG_PARTY_EMPLOYMENT__TOTAL_YEARS_OF_EXPERIENCE'
  USED_CAR_DEALER_OCCUPATION_INDICATOR: 'AUG_PARTY_EMPLOYMENT__USED_CAR_DEALER_OCCUPATION_INDICATOR'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v10_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
