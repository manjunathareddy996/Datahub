-- automate_dv.stage() for SAT_AUG_FINTXN_CLAIM_PAYMENT, read off central view stitch_v11_claim.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v11_claim'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PAY_TO_HOSPITAL_INDICATOR'
      - 'PAY_TO_INSURED_INDICATOR'
derived_columns:
  FINANCIAL_TRANSACTION_NK: "case when coalesce(AUG_FINTXN_CLAIM_PAYMENT__PAY_TO_HOSPITAL_INDICATOR, AUG_FINTXN_CLAIM_PAYMENT__PAY_TO_INSURED_INDICATOR) is not null then 'HUB_FINANCIAL_TRANSACTION|' || FINANCIAL_TRANSACTION_BK end"
  PAY_TO_HOSPITAL_INDICATOR: 'AUG_FINTXN_CLAIM_PAYMENT__PAY_TO_HOSPITAL_INDICATOR'
  PAY_TO_INSURED_INDICATOR: 'AUG_FINTXN_CLAIM_PAYMENT__PAY_TO_INSURED_INDICATOR'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v11_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
