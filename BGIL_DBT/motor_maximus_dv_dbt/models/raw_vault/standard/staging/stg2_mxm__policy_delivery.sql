-- automate_dv.stage() for SAT_POLICY_DELIVERY, read off central view stitch_mxm__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v09_party'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DELIVERY_MODE'
      - 'DISPATCH_DATE'
      - 'EDELIVERY_INDICATOR'
      - 'TRACKING_REFERENCE'
derived_columns:
  POLICY_NK: "case when coalesce(POLICY_DELIVERY__DELIVERY_MODE, POLICY_DELIVERY__DISPATCH_DATE, POLICY_DELIVERY__EDELIVERY_INDICATOR, POLICY_DELIVERY__TRACKING_REFERENCE) is not null then 'HUB_POLICY|' || POLICY_BK end"
  DELIVERY_MODE: 'POLICY_DELIVERY__DELIVERY_MODE'
  DISPATCH_DATE: 'POLICY_DELIVERY__DISPATCH_DATE'
  EDELIVERY_INDICATOR: 'POLICY_DELIVERY__EDELIVERY_INDICATOR'
  TRACKING_REFERENCE: 'POLICY_DELIVERY__TRACKING_REFERENCE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v09_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
