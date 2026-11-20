-- automate_dv.stage() for SAT_CLAIM_SETTLEMENT, read off central view stitch_mxm__v03_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v03_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'APPROVED_AMOUNT'
      - 'PAYMENT_DUE_DATE'
      - 'PAYMENT_MODE'
      - 'REQUESTED_BY_REFERENCE'
      - 'SETTLEMENT_AMOUNT'
      - 'SETTLEMENT_BASIS'
      - 'SETTLEMENT_TYPE'
derived_columns:
  CLAIM_NK: "case when coalesce(CLAIM_SETTLEMENT__APPROVED_AMOUNT, CLAIM_SETTLEMENT__PAYMENT_DUE_DATE, CLAIM_SETTLEMENT__PAYMENT_MODE, CLAIM_SETTLEMENT__REQUESTED_BY_REFERENCE, CLAIM_SETTLEMENT__SETTLEMENT_AMOUNT, CLAIM_SETTLEMENT__SETTLEMENT_BASIS, CLAIM_SETTLEMENT__SETTLEMENT_TYPE) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  APPROVED_AMOUNT: 'CLAIM_SETTLEMENT__APPROVED_AMOUNT'
  PAYMENT_DUE_DATE: 'CLAIM_SETTLEMENT__PAYMENT_DUE_DATE'
  PAYMENT_MODE: 'CLAIM_SETTLEMENT__PAYMENT_MODE'
  REQUESTED_BY_REFERENCE: 'CLAIM_SETTLEMENT__REQUESTED_BY_REFERENCE'
  SETTLEMENT_AMOUNT: 'CLAIM_SETTLEMENT__SETTLEMENT_AMOUNT'
  SETTLEMENT_BASIS: 'CLAIM_SETTLEMENT__SETTLEMENT_BASIS'
  SETTLEMENT_TYPE: 'CLAIM_SETTLEMENT__SETTLEMENT_TYPE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v03_claim'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
