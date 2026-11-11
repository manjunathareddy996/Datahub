-- automate_dv.stage() for SAT_CLAIM_RESERVE, read off central view stitch_v05_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v05_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CURRENT_RESERVE_AMOUNT'
      - 'OUTSTANDING_RESERVE_AMOUNT'
      - 'PAID_TO_DATE_AMOUNT'
      - 'RESERVE_REVISION_DATE'
      - 'RESERVE_REVISION_REASON'
      - 'RESERVE_SET_BY_REFERENCE'
      - 'RESERVE_STATUS'
      - 'RESERVE_TYPE'
      - 'RESERVE_HEAD_CK'
derived_columns:
  CLAIM_NK: "case when coalesce(CLAIM_RESERVE__CURRENT_RESERVE_AMOUNT, CLAIM_RESERVE__OUTSTANDING_RESERVE_AMOUNT, CLAIM_RESERVE__PAID_TO_DATE_AMOUNT, CLAIM_RESERVE__RESERVE_REVISION_DATE, CLAIM_RESERVE__RESERVE_REVISION_REASON, CLAIM_RESERVE__RESERVE_SET_BY_REFERENCE, CLAIM_RESERVE__RESERVE_STATUS, CLAIM_RESERVE__RESERVE_TYPE) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  RESERVE_HEAD_CK: 'CLAIM_RESERVE__RESERVE_HEAD_CK'
  CURRENT_RESERVE_AMOUNT: 'CLAIM_RESERVE__CURRENT_RESERVE_AMOUNT'
  OUTSTANDING_RESERVE_AMOUNT: 'CLAIM_RESERVE__OUTSTANDING_RESERVE_AMOUNT'
  PAID_TO_DATE_AMOUNT: 'CLAIM_RESERVE__PAID_TO_DATE_AMOUNT'
  RESERVE_REVISION_DATE: 'CLAIM_RESERVE__RESERVE_REVISION_DATE'
  RESERVE_REVISION_REASON: 'CLAIM_RESERVE__RESERVE_REVISION_REASON'
  RESERVE_SET_BY_REFERENCE: 'CLAIM_RESERVE__RESERVE_SET_BY_REFERENCE'
  RESERVE_STATUS: 'CLAIM_RESERVE__RESERVE_STATUS'
  RESERVE_TYPE: 'CLAIM_RESERVE__RESERVE_TYPE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v05_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
