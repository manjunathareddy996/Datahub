-- automate_dv.stage() for SAT_CLAIM_RESERVE_HEAD, read off central view stitch_v05_claim.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v05_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'OPENING_RESERVE'
      - 'RESERVE_HEAD_CODE_CK'
derived_columns:
  CLAIM_NK: "case when CLAIM_RESERVE_HEAD__OPENING_RESERVE is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  RESERVE_HEAD_CODE_CK: 'CLAIM_RESERVE_HEAD__RESERVE_HEAD_CODE_CK'
  OPENING_RESERVE: 'CLAIM_RESERVE_HEAD__OPENING_RESERVE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v05_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
