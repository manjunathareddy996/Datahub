-- automate_dv.stage() for SAT_CLAIM_MACT_AWARD_HEAD, read off central view stitch_mxm__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v09_party'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AWARDED_AMOUNT'
      - 'INTEREST_AMOUNT'
      - 'AWARD_HEAD_CODE_CK'
derived_columns:
  CLAIM_NK: "case when coalesce(CLAIM_MACT_AWARD_HEAD__AWARDED_AMOUNT, CLAIM_MACT_AWARD_HEAD__INTEREST_AMOUNT) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  AWARD_HEAD_CODE_CK: 'CLAIM_MACT_AWARD_HEAD__AWARD_HEAD_CODE_CK'
  AWARDED_AMOUNT: 'CLAIM_MACT_AWARD_HEAD__AWARDED_AMOUNT'
  INTEREST_AMOUNT: 'CLAIM_MACT_AWARD_HEAD__INTEREST_AMOUNT'
  LOAD_DATETIME: 'CLAIM_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v09_party'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
