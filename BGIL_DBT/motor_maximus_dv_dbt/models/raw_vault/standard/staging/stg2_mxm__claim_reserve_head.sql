-- automate_dv.stage() for SAT_CLAIM_RESERVE_HEAD, read off central view stitch_mxm__v03_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v03_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'HEAD_DESCRIPTION'
      - 'OPENING_RESERVE'
      - 'OUTSTANDING_AGAINST_HEAD'
      - 'PAID_AGAINST_HEAD'
      - 'RESERVE_HEAD_CODE'
      - 'REVISED_RESERVE'
      - 'RESERVE_HEAD_CODE_CK'
derived_columns:
  CLAIM_NK: "case when coalesce(CLAIM_RESERVE_HEAD__HEAD_DESCRIPTION, CLAIM_RESERVE_HEAD__OPENING_RESERVE, CLAIM_RESERVE_HEAD__OUTSTANDING_AGAINST_HEAD, CLAIM_RESERVE_HEAD__PAID_AGAINST_HEAD, CLAIM_RESERVE_HEAD__RESERVE_HEAD_CODE, CLAIM_RESERVE_HEAD__REVISED_RESERVE) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  RESERVE_HEAD_CODE_CK: 'CLAIM_RESERVE_HEAD__RESERVE_HEAD_CODE_CK'
  HEAD_DESCRIPTION: 'CLAIM_RESERVE_HEAD__HEAD_DESCRIPTION'
  OPENING_RESERVE: 'CLAIM_RESERVE_HEAD__OPENING_RESERVE'
  OUTSTANDING_AGAINST_HEAD: 'CLAIM_RESERVE_HEAD__OUTSTANDING_AGAINST_HEAD'
  PAID_AGAINST_HEAD: 'CLAIM_RESERVE_HEAD__PAID_AGAINST_HEAD'
  RESERVE_HEAD_CODE: 'CLAIM_RESERVE_HEAD__RESERVE_HEAD_CODE'
  REVISED_RESERVE: 'CLAIM_RESERVE_HEAD__REVISED_RESERVE'
  LOAD_DATETIME: 'CLAIM_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v03_claim'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
