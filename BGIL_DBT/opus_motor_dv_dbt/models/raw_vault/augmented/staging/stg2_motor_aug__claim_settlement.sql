-- automate_dv.stage() for SAT_MOTOR_AUG_CLAIM_SETTLEMENT, read off central view stitch_motor__v03_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v03_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AML_WAIVER_REASON'
      - 'INTEREST_RATE_PERCENTAGE'
      - 'NEFT_DETAILS_VERIFIED_INDICATOR'
      - 'OTSP_INDICATOR'
      - 'OTSP_REASON'
      - 'SETTLEMENT_FILE_NUMBER'
derived_columns:
  CLAIM_NK: "case when coalesce(AUG_CLAIM_SETTLEMENT__AML_WAIVER_REASON, AUG_CLAIM_SETTLEMENT__INTEREST_RATE_PERCENTAGE, AUG_CLAIM_SETTLEMENT__NEFT_DETAILS_VERIFIED_INDICATOR, AUG_CLAIM_SETTLEMENT__OTSP_INDICATOR, AUG_CLAIM_SETTLEMENT__OTSP_REASON, AUG_CLAIM_SETTLEMENT__SETTLEMENT_FILE_NUMBER) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  AML_WAIVER_REASON: 'AUG_CLAIM_SETTLEMENT__AML_WAIVER_REASON'
  INTEREST_RATE_PERCENTAGE: 'AUG_CLAIM_SETTLEMENT__INTEREST_RATE_PERCENTAGE'
  NEFT_DETAILS_VERIFIED_INDICATOR: 'AUG_CLAIM_SETTLEMENT__NEFT_DETAILS_VERIFIED_INDICATOR'
  OTSP_INDICATOR: 'AUG_CLAIM_SETTLEMENT__OTSP_INDICATOR'
  OTSP_REASON: 'AUG_CLAIM_SETTLEMENT__OTSP_REASON'
  SETTLEMENT_FILE_NUMBER: 'AUG_CLAIM_SETTLEMENT__SETTLEMENT_FILE_NUMBER'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_stitch_motor__v03_claim'
  SOURCE_SYSTEM: '!OPUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
