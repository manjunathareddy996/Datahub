-- automate_dv.stage() for SAT_MOTOR_AUG_PROPOSAL_UNDERWRITING, read off central view stitch_motor__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v09_party'
hashed_columns:
  PROPOSAL_HKEY: 'PROPOSAL_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DRIVING_OFFENCE_SCORE'
      - 'MANUAL_APPROVAL_INDICATOR'
      - 'PARTIAL_LOSS_PROPENSITY_SCORE'
      - 'PINCODE_ELIGIBILITY_CONDITION'
      - 'REFERRED_BY_REFERENCE'
derived_columns:
  PROPOSAL_NK: "case when coalesce(AUG_PROPOSAL_UNDERWRITING__DRIVING_OFFENCE_SCORE, AUG_PROPOSAL_UNDERWRITING__MANUAL_APPROVAL_INDICATOR, AUG_PROPOSAL_UNDERWRITING__PARTIAL_LOSS_PROPENSITY_SCORE, AUG_PROPOSAL_UNDERWRITING__PINCODE_ELIGIBILITY_CONDITION, AUG_PROPOSAL_UNDERWRITING__REFERRED_BY_REFERENCE) is not null then 'HUB_PROPOSAL|' || PROPOSAL_BK end"
  DRIVING_OFFENCE_SCORE: 'AUG_PROPOSAL_UNDERWRITING__DRIVING_OFFENCE_SCORE'
  MANUAL_APPROVAL_INDICATOR: 'AUG_PROPOSAL_UNDERWRITING__MANUAL_APPROVAL_INDICATOR'
  PARTIAL_LOSS_PROPENSITY_SCORE: 'AUG_PROPOSAL_UNDERWRITING__PARTIAL_LOSS_PROPENSITY_SCORE'
  PINCODE_ELIGIBILITY_CONDITION: 'AUG_PROPOSAL_UNDERWRITING__PINCODE_ELIGIBILITY_CONDITION'
  REFERRED_BY_REFERENCE: 'AUG_PROPOSAL_UNDERWRITING__REFERRED_BY_REFERENCE'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_MOTOR_V09_PARTY'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
