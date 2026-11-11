-- automate_dv.stage() for SAT_CLAIM_PROVIDER_BILLING, read off central view stitch_v02_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v02_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BILLED_AMOUNT'
      - 'BILL_NUMBER'
      - 'DISALLOWANCE_REASON'
      - 'DISALLOWED_AMOUNT'
      - 'BILL_NUMBER_CK'
derived_columns:
  CLAIM_NK: "case when coalesce(CLAIM_PROVIDER_BILLING__BILLED_AMOUNT, CLAIM_PROVIDER_BILLING__BILL_NUMBER, CLAIM_PROVIDER_BILLING__DISALLOWANCE_REASON, CLAIM_PROVIDER_BILLING__DISALLOWED_AMOUNT) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  BILL_NUMBER_CK: 'CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK'
  BILLED_AMOUNT: 'CLAIM_PROVIDER_BILLING__BILLED_AMOUNT'
  BILL_NUMBER: 'CLAIM_PROVIDER_BILLING__BILL_NUMBER'
  DISALLOWANCE_REASON: 'CLAIM_PROVIDER_BILLING__DISALLOWANCE_REASON'
  DISALLOWED_AMOUNT: 'CLAIM_PROVIDER_BILLING__DISALLOWED_AMOUNT'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v02_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
