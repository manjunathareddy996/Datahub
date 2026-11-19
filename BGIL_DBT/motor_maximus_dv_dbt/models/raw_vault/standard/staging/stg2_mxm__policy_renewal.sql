-- automate_dv.stage() for SAT_POLICY_RENEWAL, read off central view stitch_mxm__v14_risk_object.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v14_risk_object'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BREAK_IN_INDICATOR'
      - 'RENEWAL_BLOCK_REASON'
      - 'RENEWAL_DUE_DATE'
      - 'RENEWAL_STATUS'
derived_columns:
  POLICY_NK: "case when coalesce(POLICY_RENEWAL__BREAK_IN_INDICATOR, POLICY_RENEWAL__RENEWAL_BLOCK_REASON, POLICY_RENEWAL__RENEWAL_DUE_DATE, POLICY_RENEWAL__RENEWAL_STATUS) is not null then 'HUB_POLICY|' || POLICY_BK end"
  BREAK_IN_INDICATOR: 'POLICY_RENEWAL__BREAK_IN_INDICATOR'
  RENEWAL_BLOCK_REASON: 'POLICY_RENEWAL__RENEWAL_BLOCK_REASON'
  RENEWAL_DUE_DATE: 'POLICY_RENEWAL__RENEWAL_DUE_DATE'
  RENEWAL_STATUS: 'POLICY_RENEWAL__RENEWAL_STATUS'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v14_risk_object'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
