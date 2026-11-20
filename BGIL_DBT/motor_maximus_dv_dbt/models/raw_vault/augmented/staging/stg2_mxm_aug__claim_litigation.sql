-- automate_dv.stage() for SAT_MOTOR_AUG_CLAIM_LITIGATION, read off central view stitch_mxm__v03_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v03_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COURT_LOCATION'
      - 'DEFENSE_CLASSIFICATION'
      - 'DEFENSE_SEVERITY'
      - 'DEFENSE_STATUS'
      - 'DEFENSE_TRIGGER_TYPE'
      - 'DEFENSE_TYPE'
derived_columns:
  CLAIM_NK: "case when coalesce(AUG_CLAIM_LITIGATION__COURT_LOCATION, AUG_CLAIM_LITIGATION__DEFENSE_CLASSIFICATION, AUG_CLAIM_LITIGATION__DEFENSE_SEVERITY, AUG_CLAIM_LITIGATION__DEFENSE_STATUS, AUG_CLAIM_LITIGATION__DEFENSE_TRIGGER_TYPE, AUG_CLAIM_LITIGATION__DEFENSE_TYPE) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  COURT_LOCATION: 'AUG_CLAIM_LITIGATION__COURT_LOCATION'
  DEFENSE_CLASSIFICATION: 'AUG_CLAIM_LITIGATION__DEFENSE_CLASSIFICATION'
  DEFENSE_SEVERITY: 'AUG_CLAIM_LITIGATION__DEFENSE_SEVERITY'
  DEFENSE_STATUS: 'AUG_CLAIM_LITIGATION__DEFENSE_STATUS'
  DEFENSE_TRIGGER_TYPE: 'AUG_CLAIM_LITIGATION__DEFENSE_TRIGGER_TYPE'
  DEFENSE_TYPE: 'AUG_CLAIM_LITIGATION__DEFENSE_TYPE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v03_claim'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
