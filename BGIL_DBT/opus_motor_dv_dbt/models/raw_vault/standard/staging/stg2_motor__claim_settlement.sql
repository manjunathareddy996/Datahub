-- automate_dv.stage() for SAT_CLAIM_SETTLEMENT, read off central view stitch_motor__v03_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v03_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AML_WAIVER_INDICATOR'
      - 'INTEREST_PAID_AMOUNT'
      - 'PAYMENT_DUE_DATE'
      - 'SETTLEMENT_AMOUNT'
      - 'SETTLEMENT_TYPE'
derived_columns:
  CLAIM_NK: "case when coalesce(CLAIM_SETTLEMENT__AML_WAIVER_INDICATOR, CLAIM_SETTLEMENT__INTEREST_PAID_AMOUNT, CLAIM_SETTLEMENT__PAYMENT_DUE_DATE, CLAIM_SETTLEMENT__SETTLEMENT_AMOUNT, CLAIM_SETTLEMENT__SETTLEMENT_TYPE) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  AML_WAIVER_INDICATOR: 'CLAIM_SETTLEMENT__AML_WAIVER_INDICATOR'
  INTEREST_PAID_AMOUNT: 'CLAIM_SETTLEMENT__INTEREST_PAID_AMOUNT'
  PAYMENT_DUE_DATE: 'CLAIM_SETTLEMENT__PAYMENT_DUE_DATE'
  SETTLEMENT_AMOUNT: 'CLAIM_SETTLEMENT__SETTLEMENT_AMOUNT'
  SETTLEMENT_TYPE: 'CLAIM_SETTLEMENT__SETTLEMENT_TYPE'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_stitch_motor__v03_claim'
  SOURCE_SYSTEM: '!OPUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
