-- automate_dv.stage() for SAT_CLAIM_RESERVE, read off central view stitch_mxm__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v09_party'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CURRENT_RESERVE_AMOUNT'
      - 'INITIAL_RESERVE_AMOUNT'
      - 'RESERVE_TYPE'
      - 'RESERVE_HEAD_CK'
derived_columns:
  CLAIM_NK: "case when coalesce(CLAIM_RESERVE__CURRENT_RESERVE_AMOUNT, CLAIM_RESERVE__INITIAL_RESERVE_AMOUNT, CLAIM_RESERVE__RESERVE_TYPE) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  RESERVE_HEAD_CK: 'CLAIM_RESERVE__RESERVE_HEAD_CK'
  CURRENT_RESERVE_AMOUNT: 'CLAIM_RESERVE__CURRENT_RESERVE_AMOUNT'
  INITIAL_RESERVE_AMOUNT: 'CLAIM_RESERVE__INITIAL_RESERVE_AMOUNT'
  RESERVE_TYPE: 'CLAIM_RESERVE__RESERVE_TYPE'
  LOAD_DATETIME: 'CLAIM_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!stitch_mxm__v09_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
