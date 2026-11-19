-- automate_dv.stage() for SAT_CLAIM_DEDUCTION_WAIVER, read off central view stitch_mxm__v01_assessment.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v01_assessment'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'GOODWILL_AMOUNT'
      - 'GOODWILL_INDICATOR'
      - 'WAIVER_INDICATOR'
derived_columns:
  CLAIM_NK: "case when coalesce(CLAIM_DEDUCTION_WAIVER__GOODWILL_AMOUNT, CLAIM_DEDUCTION_WAIVER__GOODWILL_INDICATOR, CLAIM_DEDUCTION_WAIVER__WAIVER_INDICATOR) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  GOODWILL_AMOUNT: 'CLAIM_DEDUCTION_WAIVER__GOODWILL_AMOUNT'
  GOODWILL_INDICATOR: 'CLAIM_DEDUCTION_WAIVER__GOODWILL_INDICATOR'
  WAIVER_INDICATOR: 'CLAIM_DEDUCTION_WAIVER__WAIVER_INDICATOR'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v01_assessment'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
