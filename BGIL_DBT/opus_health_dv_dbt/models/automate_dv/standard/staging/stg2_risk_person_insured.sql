-- automate_dv.stage() for SAT_RISK_PERSON_INSURED, read off central view stitch_v34_risk_object.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v34_risk_object'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BODY_MASS_INDEX'
      - 'HEALTH_CARD_NUMBER'
      - 'HEIGHT'
      - 'MEMBER_RISK_LOADING_PERCENTAGE'
      - 'PRE_EXISTING_DISEASE_DESCRIPTION'
      - 'RELATIONSHIP_TO_PROPOSER'
      - 'SMOKER_INDICATOR'
      - 'WEIGHT'
derived_columns:
  RISK_OBJECT_NK: "case when coalesce(RISK_PERSON_INSURED__BODY_MASS_INDEX, RISK_PERSON_INSURED__HEALTH_CARD_NUMBER, RISK_PERSON_INSURED__HEIGHT, RISK_PERSON_INSURED__MEMBER_RISK_LOADING_PERCENTAGE, RISK_PERSON_INSURED__PRE_EXISTING_DISEASE_DESCRIPTION, RISK_PERSON_INSURED__RELATIONSHIP_TO_PROPOSER, RISK_PERSON_INSURED__SMOKER_INDICATOR, RISK_PERSON_INSURED__WEIGHT) is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  BODY_MASS_INDEX: 'RISK_PERSON_INSURED__BODY_MASS_INDEX'
  HEALTH_CARD_NUMBER: 'RISK_PERSON_INSURED__HEALTH_CARD_NUMBER'
  HEIGHT: 'RISK_PERSON_INSURED__HEIGHT'
  MEMBER_RISK_LOADING_PERCENTAGE: 'RISK_PERSON_INSURED__MEMBER_RISK_LOADING_PERCENTAGE'
  PRE_EXISTING_DISEASE_DESCRIPTION: 'RISK_PERSON_INSURED__PRE_EXISTING_DISEASE_DESCRIPTION'
  RELATIONSHIP_TO_PROPOSER: 'RISK_PERSON_INSURED__RELATIONSHIP_TO_PROPOSER'
  SMOKER_INDICATOR: 'RISK_PERSON_INSURED__SMOKER_INDICATOR'
  WEIGHT: 'RISK_PERSON_INSURED__WEIGHT'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v34_risk_object'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
