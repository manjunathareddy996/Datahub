-- automate_dv.stage() for SAT_MOTOR_AUG_CLAIM_EXCESS_HEAD, read off central view stitch_mxm__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v09_party'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'EXCESS_AMOUNT'
      - 'EXCESS_WAIVED_INDICATOR'
      - 'EXCESS_WAIVER_REASON'
      - 'EXCESS_TYPE_CODE_CK'
derived_columns:
  CLAIM_NK: "case when coalesce(AUG_CLAIM_EXCESS_HEAD__EXCESS_AMOUNT, AUG_CLAIM_EXCESS_HEAD__EXCESS_WAIVED_INDICATOR, AUG_CLAIM_EXCESS_HEAD__EXCESS_WAIVER_REASON) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  EXCESS_TYPE_CODE_CK: 'AUG_CLAIM_EXCESS_HEAD__EXCESS_TYPE_CODE_CK'
  EXCESS_AMOUNT: 'AUG_CLAIM_EXCESS_HEAD__EXCESS_AMOUNT'
  EXCESS_WAIVED_INDICATOR: 'AUG_CLAIM_EXCESS_HEAD__EXCESS_WAIVED_INDICATOR'
  EXCESS_WAIVER_REASON: 'AUG_CLAIM_EXCESS_HEAD__EXCESS_WAIVER_REASON'
  LOAD_DATETIME: 'CLAIM_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v09_party'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
