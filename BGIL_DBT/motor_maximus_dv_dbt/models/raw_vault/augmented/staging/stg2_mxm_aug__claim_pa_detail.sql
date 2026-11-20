-- automate_dv.stage() for SAT_MOTOR_AUG_CLAIM_PA_DETAIL, read off central view stitch_mxm__v03_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v03_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CAUSE_OF_LOSS'
      - 'INJURY_CATEGORY'
      - 'INJURY_OR_DEATH_CLASSIFICATION'
      - 'PA_CLAIM_INDICATOR'
      - 'PERSONAL_ACCIDENT_CLAIM_FOR'
      - 'SCALE_OF_COMPENSATION'
derived_columns:
  CLAIM_NK: "case when coalesce(AUG_CLAIM_PA_DETAIL__CAUSE_OF_LOSS, AUG_CLAIM_PA_DETAIL__INJURY_CATEGORY, AUG_CLAIM_PA_DETAIL__INJURY_OR_DEATH_CLASSIFICATION, AUG_CLAIM_PA_DETAIL__PA_CLAIM_INDICATOR, AUG_CLAIM_PA_DETAIL__PERSONAL_ACCIDENT_CLAIM_FOR, AUG_CLAIM_PA_DETAIL__SCALE_OF_COMPENSATION) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  CAUSE_OF_LOSS: 'AUG_CLAIM_PA_DETAIL__CAUSE_OF_LOSS'
  INJURY_CATEGORY: 'AUG_CLAIM_PA_DETAIL__INJURY_CATEGORY'
  INJURY_OR_DEATH_CLASSIFICATION: 'AUG_CLAIM_PA_DETAIL__INJURY_OR_DEATH_CLASSIFICATION'
  PA_CLAIM_INDICATOR: 'AUG_CLAIM_PA_DETAIL__PA_CLAIM_INDICATOR'
  PERSONAL_ACCIDENT_CLAIM_FOR: 'AUG_CLAIM_PA_DETAIL__PERSONAL_ACCIDENT_CLAIM_FOR'
  SCALE_OF_COMPENSATION: 'AUG_CLAIM_PA_DETAIL__SCALE_OF_COMPENSATION'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v03_claim'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
