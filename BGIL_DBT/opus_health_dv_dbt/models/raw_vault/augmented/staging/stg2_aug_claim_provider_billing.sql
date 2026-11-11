-- automate_dv.stage() for SAT_AUG_CLAIM_PROVIDER_BILLING, read off central view stitch_v08_claim.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v08_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BILL_ADJUDICATED_BY_USER'
      - 'BILL_ADJUDICATION_TIMESTAMP'
      - 'CLAIMED_AMOUNT'
      - 'CO_PAY_AMOUNT'
      - 'DISCOUNT_AMOUNT'
      - 'MOU_APPROVED_AMOUNT'
      - 'PATIENT_PAID_AMOUNT'
      - 'RELATED_BILL_REFERENCE'
derived_columns:
  CLAIM_NK: "case when coalesce(AUG_CLAIM_PROVIDER_BILLING__BILL_ADJUDICATED_BY_USER, AUG_CLAIM_PROVIDER_BILLING__BILL_ADJUDICATION_TIMESTAMP, AUG_CLAIM_PROVIDER_BILLING__CLAIMED_AMOUNT, AUG_CLAIM_PROVIDER_BILLING__CO_PAY_AMOUNT, AUG_CLAIM_PROVIDER_BILLING__DISCOUNT_AMOUNT, AUG_CLAIM_PROVIDER_BILLING__MOU_APPROVED_AMOUNT, AUG_CLAIM_PROVIDER_BILLING__PATIENT_PAID_AMOUNT, AUG_CLAIM_PROVIDER_BILLING__RELATED_BILL_REFERENCE) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  BILL_ADJUDICATED_BY_USER: 'AUG_CLAIM_PROVIDER_BILLING__BILL_ADJUDICATED_BY_USER'
  BILL_ADJUDICATION_TIMESTAMP: 'AUG_CLAIM_PROVIDER_BILLING__BILL_ADJUDICATION_TIMESTAMP'
  CLAIMED_AMOUNT: 'AUG_CLAIM_PROVIDER_BILLING__CLAIMED_AMOUNT'
  CO_PAY_AMOUNT: 'AUG_CLAIM_PROVIDER_BILLING__CO_PAY_AMOUNT'
  DISCOUNT_AMOUNT: 'AUG_CLAIM_PROVIDER_BILLING__DISCOUNT_AMOUNT'
  MOU_APPROVED_AMOUNT: 'AUG_CLAIM_PROVIDER_BILLING__MOU_APPROVED_AMOUNT'
  PATIENT_PAID_AMOUNT: 'AUG_CLAIM_PROVIDER_BILLING__PATIENT_PAID_AMOUNT'
  RELATED_BILL_REFERENCE: 'AUG_CLAIM_PROVIDER_BILLING__RELATED_BILL_REFERENCE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v08_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
