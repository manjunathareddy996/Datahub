-- automate_dv.stage() for SAT_CLAIM_SETTLEMENT, read off central view stitch_v04_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v04_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'APPROVED_AMOUNT'
      - 'NEGOTIATION_AMOUNT'
      - 'PENAL_INTEREST_AMOUNT'
      - 'SETTLEMENT_AMOUNT'
derived_columns:
  CLAIM_NK: "case when coalesce(CLAIM_SETTLEMENT__APPROVED_AMOUNT, CLAIM_SETTLEMENT__NEGOTIATION_AMOUNT, CLAIM_SETTLEMENT__PENAL_INTEREST_AMOUNT, CLAIM_SETTLEMENT__SETTLEMENT_AMOUNT) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  APPROVED_AMOUNT: 'CLAIM_SETTLEMENT__APPROVED_AMOUNT'
  NEGOTIATION_AMOUNT: 'CLAIM_SETTLEMENT__NEGOTIATION_AMOUNT'
  PENAL_INTEREST_AMOUNT: 'CLAIM_SETTLEMENT__PENAL_INTEREST_AMOUNT'
  SETTLEMENT_AMOUNT: 'CLAIM_SETTLEMENT__SETTLEMENT_AMOUNT'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v04_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
