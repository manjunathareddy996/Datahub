-- automate_dv.stage() for SAT_MOTOR_AUG_COMMON_ADMIN_GEOGRAPHY, read off central view stitch_mxm__v12_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v12_policy'
hashed_columns:
  LOCATION_HKEY: 'LOCATION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'RTO_CLUSTER_CODE'
derived_columns:
  LOCATION_NK: "case when AUG_COMMON_ADMIN_GEOGRAPHY__RTO_CLUSTER_CODE is not null then 'HUB_LOCATION|' || LOCATION_BK end"
  RTO_CLUSTER_CODE: 'AUG_COMMON_ADMIN_GEOGRAPHY__RTO_CLUSTER_CODE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v12_policy'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
