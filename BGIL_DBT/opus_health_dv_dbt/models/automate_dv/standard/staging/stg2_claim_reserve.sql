-- automate_dv.stage() for SAT_CLAIM_RESERVE, read off central view stitch_v09_claim.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v09_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CURRENT_RESERVE_AMOUNT'
      - 'RESERVE_HEAD_CK'
derived_columns:
  CLAIM_NK: "case when CLAIM_RESERVE__CURRENT_RESERVE_AMOUNT is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  RESERVE_HEAD_CK: 'CLAIM_RESERVE__RESERVE_HEAD_CK'
  CURRENT_RESERVE_AMOUNT: 'CLAIM_RESERVE__CURRENT_RESERVE_AMOUNT'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v09_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
