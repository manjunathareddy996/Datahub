-- automate_dv.stage() for SAT_MOTOR_AUG_CLAIM_BILL_LINE, read off central view stitch_mxm__v03_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v03_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'LINE_PARTICULAR'
      - 'BILL_LINE_TYPE_CK'
      - 'BILL_HEAD_CODE_CK'
      - 'LINE_PARTICULAR_CK'
derived_columns:
  CLAIM_NK: "case when AUG_CLAIM_BILL_LINE__LINE_PARTICULAR is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  BILL_LINE_TYPE_CK: 'AUG_CLAIM_BILL_LINE__BILL_LINE_TYPE_CK'
  BILL_HEAD_CODE_CK: 'AUG_CLAIM_BILL_LINE__BILL_HEAD_CODE_CK'
  LINE_PARTICULAR_CK: 'AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_CK'
  LINE_PARTICULAR: 'AUG_CLAIM_BILL_LINE__LINE_PARTICULAR'
  LOAD_DATETIME: 'CLAIM_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!stitch_mxm__v03_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
