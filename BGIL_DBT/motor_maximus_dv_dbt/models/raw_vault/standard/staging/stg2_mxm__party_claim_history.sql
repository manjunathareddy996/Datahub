-- automate_dv.stage() for SAT_PARTY_CLAIM_HISTORY, read off central view stitch_mxm__v04_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v04_claim'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'MOTOR_CLAIM_COUNT'
      - 'TOTAL_CLAIM_AMOUNT'
derived_columns:
  PARTY_NK: "case when coalesce(PARTY_CLAIM_HISTORY__MOTOR_CLAIM_COUNT, PARTY_CLAIM_HISTORY__TOTAL_CLAIM_AMOUNT) is not null then 'HUB_PARTY|' || PARTY_BK end"
  MOTOR_CLAIM_COUNT: 'PARTY_CLAIM_HISTORY__MOTOR_CLAIM_COUNT'
  TOTAL_CLAIM_AMOUNT: 'PARTY_CLAIM_HISTORY__TOTAL_CLAIM_AMOUNT'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v04_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
