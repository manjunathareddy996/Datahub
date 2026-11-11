-- automate_dv.stage() for SAT_PARTY_ONBOARDING_JOURNEY, read off central view stitch_v11_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v11_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'EXAMINATION_REFERENCE'
      - 'EXAMINATION_RESULT'
      - 'ONBOARDING_START_DATE'
      - 'PREVIOUS_EMPLOYER_NAME'
      - 'PRIOR_WORK_EXPERIENCE_YEARS'
derived_columns:
  PARTY_NK: "case when coalesce(PARTY_ONBOARDING_JOURNEY__EXAMINATION_REFERENCE, PARTY_ONBOARDING_JOURNEY__EXAMINATION_RESULT, PARTY_ONBOARDING_JOURNEY__ONBOARDING_START_DATE, PARTY_ONBOARDING_JOURNEY__PREVIOUS_EMPLOYER_NAME, PARTY_ONBOARDING_JOURNEY__PRIOR_WORK_EXPERIENCE_YEARS) is not null then 'HUB_PARTY|' || PARTY_BK end"
  EXAMINATION_REFERENCE: 'PARTY_ONBOARDING_JOURNEY__EXAMINATION_REFERENCE'
  EXAMINATION_RESULT: 'PARTY_ONBOARDING_JOURNEY__EXAMINATION_RESULT'
  ONBOARDING_START_DATE: 'PARTY_ONBOARDING_JOURNEY__ONBOARDING_START_DATE'
  PREVIOUS_EMPLOYER_NAME: 'PARTY_ONBOARDING_JOURNEY__PREVIOUS_EMPLOYER_NAME'
  PRIOR_WORK_EXPERIENCE_YEARS: 'PARTY_ONBOARDING_JOURNEY__PRIOR_WORK_EXPERIENCE_YEARS'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v11_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
