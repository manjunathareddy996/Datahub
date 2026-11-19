-- automate_dv.stage() for SAT_MOTOR_AUG_PARTY_CLAIM_HISTORY, read off central view stitch_mxm__v11_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v11_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'MOTOR_CLAIM_INDICATOR'
      - 'OWN_DAMAGE_CLAIM_SCORE'
      - 'THIRD_PARTY_CLAIM_SCORE'
derived_columns:
  PARTY_NK: "case when coalesce(AUG_PARTY_CLAIM_HISTORY__MOTOR_CLAIM_INDICATOR, AUG_PARTY_CLAIM_HISTORY__OWN_DAMAGE_CLAIM_SCORE, AUG_PARTY_CLAIM_HISTORY__THIRD_PARTY_CLAIM_SCORE) is not null then 'HUB_PARTY|' || PARTY_BK end"
  MOTOR_CLAIM_INDICATOR: 'AUG_PARTY_CLAIM_HISTORY__MOTOR_CLAIM_INDICATOR'
  OWN_DAMAGE_CLAIM_SCORE: 'AUG_PARTY_CLAIM_HISTORY__OWN_DAMAGE_CLAIM_SCORE'
  THIRD_PARTY_CLAIM_SCORE: 'AUG_PARTY_CLAIM_HISTORY__THIRD_PARTY_CLAIM_SCORE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v11_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
