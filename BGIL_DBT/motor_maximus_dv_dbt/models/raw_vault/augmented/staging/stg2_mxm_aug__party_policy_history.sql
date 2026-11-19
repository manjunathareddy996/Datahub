-- automate_dv.stage() for SAT_MOTOR_AUG_PARTY_POLICY_HISTORY, read off central view stitch_mxm__v04_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v04_claim'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'LATEST_POLICY_ISSUING_OFFICE'
      - 'LATEST_POLICY_LINE_OF_BUSINESS'
      - 'LATEST_POLICY_PRODUCT_NAME'
      - 'LATEST_POLICY_SUB_CHANNEL'
derived_columns:
  PARTY_NK: "case when coalesce(AUG_PARTY_POLICY_HISTORY__LATEST_POLICY_ISSUING_OFFICE, AUG_PARTY_POLICY_HISTORY__LATEST_POLICY_LINE_OF_BUSINESS, AUG_PARTY_POLICY_HISTORY__LATEST_POLICY_PRODUCT_NAME, AUG_PARTY_POLICY_HISTORY__LATEST_POLICY_SUB_CHANNEL) is not null then 'HUB_PARTY|' || PARTY_BK end"
  LATEST_POLICY_ISSUING_OFFICE: 'AUG_PARTY_POLICY_HISTORY__LATEST_POLICY_ISSUING_OFFICE'
  LATEST_POLICY_LINE_OF_BUSINESS: 'AUG_PARTY_POLICY_HISTORY__LATEST_POLICY_LINE_OF_BUSINESS'
  LATEST_POLICY_PRODUCT_NAME: 'AUG_PARTY_POLICY_HISTORY__LATEST_POLICY_PRODUCT_NAME'
  LATEST_POLICY_SUB_CHANNEL: 'AUG_PARTY_POLICY_HISTORY__LATEST_POLICY_SUB_CHANNEL'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v04_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
