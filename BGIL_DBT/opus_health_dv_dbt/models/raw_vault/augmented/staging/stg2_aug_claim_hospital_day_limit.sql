-- automate_dv.stage() for SAT_AUG_CLAIM_HOSPITAL_DAY_LIMIT, read off central view stitch_v05_claim.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v05_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ASSESSED_COMPONENT_VALUE'
      - 'BALANCE_DAYS'
      - 'ELIGIBLE_AMOUNT_PER_DAY'
      - 'TOTAL_DAYS'
      - 'COVER_SECTION_CODE_CK'
      - 'WARD_CLASS_CODE_CK'
derived_columns:
  CLAIM_NK: "case when coalesce(AUG_CLAIM_HOSPITAL_DAY_LIMIT__ASSESSED_COMPONENT_VALUE, AUG_CLAIM_HOSPITAL_DAY_LIMIT__BALANCE_DAYS, AUG_CLAIM_HOSPITAL_DAY_LIMIT__ELIGIBLE_AMOUNT_PER_DAY, AUG_CLAIM_HOSPITAL_DAY_LIMIT__TOTAL_DAYS) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  COVER_SECTION_CODE_CK: 'AUG_CLAIM_HOSPITAL_DAY_LIMIT__COVER_SECTION_CODE_CK'
  WARD_CLASS_CODE_CK: 'AUG_CLAIM_HOSPITAL_DAY_LIMIT__WARD_CLASS_CODE_CK'
  ASSESSED_COMPONENT_VALUE: 'AUG_CLAIM_HOSPITAL_DAY_LIMIT__ASSESSED_COMPONENT_VALUE'
  BALANCE_DAYS: 'AUG_CLAIM_HOSPITAL_DAY_LIMIT__BALANCE_DAYS'
  ELIGIBLE_AMOUNT_PER_DAY: 'AUG_CLAIM_HOSPITAL_DAY_LIMIT__ELIGIBLE_AMOUNT_PER_DAY'
  TOTAL_DAYS: 'AUG_CLAIM_HOSPITAL_DAY_LIMIT__TOTAL_DAYS'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v05_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
