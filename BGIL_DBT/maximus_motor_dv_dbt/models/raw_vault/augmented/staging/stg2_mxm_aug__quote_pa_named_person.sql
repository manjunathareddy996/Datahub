-- automate_dv.stage() for SAT_MOTOR_AUG_QUOTE_PA_NAMED_PERSON, read off central view stitch_mxm__v04_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v04_claim'
hashed_columns:
  QUOTE_HKEY: 'QUOTE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'NAMED_PERSON_AGE'
      - 'NAMED_PERSON_GENDER'
      - 'NAMED_PERSON_NAME'
      - 'NAMED_PERSON_RELATIONSHIP'
      - 'NAMED_PERSON_NAME_CK'
derived_columns:
  QUOTE_NK: "case when coalesce(AUG_QUOTE_PA_NAMED_PERSON__NAMED_PERSON_AGE, AUG_QUOTE_PA_NAMED_PERSON__NAMED_PERSON_GENDER, AUG_QUOTE_PA_NAMED_PERSON__NAMED_PERSON_NAME, AUG_QUOTE_PA_NAMED_PERSON__NAMED_PERSON_RELATIONSHIP) is not null then 'HUB_QUOTE|' || QUOTE_BK end"
  NAMED_PERSON_NAME_CK: 'AUG_QUOTE_PA_NAMED_PERSON__NAMED_PERSON_NAME_CK'
  NAMED_PERSON_AGE: 'AUG_QUOTE_PA_NAMED_PERSON__NAMED_PERSON_AGE'
  NAMED_PERSON_GENDER: 'AUG_QUOTE_PA_NAMED_PERSON__NAMED_PERSON_GENDER'
  NAMED_PERSON_NAME: 'AUG_QUOTE_PA_NAMED_PERSON__NAMED_PERSON_NAME'
  NAMED_PERSON_RELATIONSHIP: 'AUG_QUOTE_PA_NAMED_PERSON__NAMED_PERSON_RELATIONSHIP'
  LOAD_DATETIME: 'QUOTE_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v04_claim'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
