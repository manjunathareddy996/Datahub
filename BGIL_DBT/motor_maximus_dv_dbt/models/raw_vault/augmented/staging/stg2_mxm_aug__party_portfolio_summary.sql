-- automate_dv.stage() for SAT_MOTOR_AUG_PARTY_PORTFOLIO_SUMMARY, read off central view stitch_mxm__v04_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v04_claim'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'MULTI_CHANNEL_PURCHASE_INDICATOR'
derived_columns:
  PARTY_NK: "case when AUG_PARTY_PORTFOLIO_SUMMARY__MULTI_CHANNEL_PURCHASE_INDICATOR is not null then 'HUB_PARTY|' || PARTY_BK end"
  MULTI_CHANNEL_PURCHASE_INDICATOR: 'AUG_PARTY_PORTFOLIO_SUMMARY__MULTI_CHANNEL_PURCHASE_INDICATOR'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v04_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
