-- automate_dv.stage() for SAT_MOTOR_AUG_CLAIM_SETTLEMENT, read off central view stitch_mxm__v03_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v03_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CASHLESS_SETTLEMENT_TYPE'
      - 'OTSP_INDICATOR'
      - 'OTSP_REASON'
      - 'PAYEE_NAME'
      - 'SETTLEMENT_MODE_AT_ADMISSIBILITY'
      - 'SETTLEMENT_TYPE_FOR_PERSONAL_ACCIDENT'
      - 'SETTLEMENT_TYPE_FOR_TOTAL_LOSS'
derived_columns:
  CLAIM_NK: "case when coalesce(AUG_CLAIM_SETTLEMENT__CASHLESS_SETTLEMENT_TYPE, AUG_CLAIM_SETTLEMENT__OTSP_INDICATOR, AUG_CLAIM_SETTLEMENT__OTSP_REASON, AUG_CLAIM_SETTLEMENT__PAYEE_NAME, AUG_CLAIM_SETTLEMENT__SETTLEMENT_MODE_AT_ADMISSIBILITY, AUG_CLAIM_SETTLEMENT__SETTLEMENT_TYPE_FOR_PERSONAL_ACCIDENT, AUG_CLAIM_SETTLEMENT__SETTLEMENT_TYPE_FOR_TOTAL_LOSS) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  CASHLESS_SETTLEMENT_TYPE: 'AUG_CLAIM_SETTLEMENT__CASHLESS_SETTLEMENT_TYPE'
  OTSP_INDICATOR: 'AUG_CLAIM_SETTLEMENT__OTSP_INDICATOR'
  OTSP_REASON: 'AUG_CLAIM_SETTLEMENT__OTSP_REASON'
  PAYEE_NAME: 'AUG_CLAIM_SETTLEMENT__PAYEE_NAME'
  SETTLEMENT_MODE_AT_ADMISSIBILITY: 'AUG_CLAIM_SETTLEMENT__SETTLEMENT_MODE_AT_ADMISSIBILITY'
  SETTLEMENT_TYPE_FOR_PERSONAL_ACCIDENT: 'AUG_CLAIM_SETTLEMENT__SETTLEMENT_TYPE_FOR_PERSONAL_ACCIDENT'
  SETTLEMENT_TYPE_FOR_TOTAL_LOSS: 'AUG_CLAIM_SETTLEMENT__SETTLEMENT_TYPE_FOR_TOTAL_LOSS'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v03_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
