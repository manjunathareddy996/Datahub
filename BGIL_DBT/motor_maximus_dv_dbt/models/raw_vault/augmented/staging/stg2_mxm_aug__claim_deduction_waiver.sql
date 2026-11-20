-- automate_dv.stage() for SAT_MOTOR_AUG_CLAIM_DEDUCTION_WAIVER, read off central view stitch_mxm__v01_assessment.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v01_assessment'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ADDITIONAL_EXCESS_WAIVED_INDICATOR'
      - 'COMPULSORY_EXCESS_WAIVED_INDICATOR'
      - 'FRANCHISE_EXCESS_FOR_OWN_DAMAGE_WAIVED_INDICATOR'
      - 'VOLUNTARY_EXCESS_WAIVED_INDICATOR'
derived_columns:
  CLAIM_NK: "case when coalesce(AUG_CLAIM_DEDUCTION_WAIVER__ADDITIONAL_EXCESS_WAIVED_INDICATOR, AUG_CLAIM_DEDUCTION_WAIVER__COMPULSORY_EXCESS_WAIVED_INDICATOR, AUG_CLAIM_DEDUCTION_WAIVER__FRANCHISE_EXCESS_FOR_OWN_DAMAGE_WAIVED_INDICATOR, AUG_CLAIM_DEDUCTION_WAIVER__VOLUNTARY_EXCESS_WAIVED_INDICATOR) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  ADDITIONAL_EXCESS_WAIVED_INDICATOR: 'AUG_CLAIM_DEDUCTION_WAIVER__ADDITIONAL_EXCESS_WAIVED_INDICATOR'
  COMPULSORY_EXCESS_WAIVED_INDICATOR: 'AUG_CLAIM_DEDUCTION_WAIVER__COMPULSORY_EXCESS_WAIVED_INDICATOR'
  FRANCHISE_EXCESS_FOR_OWN_DAMAGE_WAIVED_INDICATOR: 'AUG_CLAIM_DEDUCTION_WAIVER__FRANCHISE_EXCESS_FOR_OWN_DAMAGE_WAIVED_INDICATOR'
  VOLUNTARY_EXCESS_WAIVED_INDICATOR: 'AUG_CLAIM_DEDUCTION_WAIVER__VOLUNTARY_EXCESS_WAIVED_INDICATOR'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v01_assessment'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
