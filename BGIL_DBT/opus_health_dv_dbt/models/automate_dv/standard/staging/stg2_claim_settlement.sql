-- automate_dv.stage() for SAT_CLAIM_SETTLEMENT, read off central view stitch_v07_claim.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v07_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'APPROVED_AMOUNT'
      - 'SETTLEMENT_AMOUNT'
      - 'SETTLEMENT_DATE'
      - 'SETTLEMENT_STATUS'
      - 'SETTLEMENT_TYPE'
derived_columns:
  CLAIM_NK: "case when coalesce(CLAIM_SETTLEMENT__APPROVED_AMOUNT, CLAIM_SETTLEMENT__SETTLEMENT_AMOUNT, CLAIM_SETTLEMENT__SETTLEMENT_DATE, CLAIM_SETTLEMENT__SETTLEMENT_STATUS, CLAIM_SETTLEMENT__SETTLEMENT_TYPE) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  APPROVED_AMOUNT: 'CLAIM_SETTLEMENT__APPROVED_AMOUNT'
  SETTLEMENT_AMOUNT: 'CLAIM_SETTLEMENT__SETTLEMENT_AMOUNT'
  SETTLEMENT_DATE: 'CLAIM_SETTLEMENT__SETTLEMENT_DATE'
  SETTLEMENT_STATUS: 'CLAIM_SETTLEMENT__SETTLEMENT_STATUS'
  SETTLEMENT_TYPE: 'CLAIM_SETTLEMENT__SETTLEMENT_TYPE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v07_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
