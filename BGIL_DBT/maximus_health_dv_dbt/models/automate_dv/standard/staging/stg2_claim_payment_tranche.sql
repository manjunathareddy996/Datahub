-- automate_dv.stage() for SAT_CLAIM_PAYMENT_TRANCHE, read off central view stitch_v05_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v05_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'GROSS_AMOUNT'
      - 'PAYMENT_TYPE'
      - 'STATUS'
      - 'TRANCHE_NUMBER_CK'
derived_columns:
  CLAIM_NK: "case when coalesce(CLAIM_PAYMENT_TRANCHE__GROSS_AMOUNT, CLAIM_PAYMENT_TRANCHE__PAYMENT_TYPE, CLAIM_PAYMENT_TRANCHE__STATUS) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  TRANCHE_NUMBER_CK: 'CLAIM_PAYMENT_TRANCHE__TRANCHE_NUMBER_CK'
  GROSS_AMOUNT: 'CLAIM_PAYMENT_TRANCHE__GROSS_AMOUNT'
  PAYMENT_TYPE: 'CLAIM_PAYMENT_TRANCHE__PAYMENT_TYPE'
  STATUS: 'CLAIM_PAYMENT_TRANCHE__STATUS'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v05_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
