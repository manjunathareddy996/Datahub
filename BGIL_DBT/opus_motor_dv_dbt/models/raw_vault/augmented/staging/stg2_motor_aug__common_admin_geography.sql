-- automate_dv.stage() for SAT_MOTOR_AUG_COMMON_ADMIN_GEOGRAPHY, read off central view stitch_motor__v07_location.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v07_location'
hashed_columns:
  LOCATION_HKEY: 'LOCATION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COMMERCIAL_REGISTRATION_ZONE'
      - 'EFFECTIVE_DATE'
      - 'EXPIRY_DATE'
      - 'REGISTRATION_ZONE'
      - 'RTO_CLUSTER_CODE'
derived_columns:
  LOCATION_NK: "case when coalesce(AUG_COMMON_ADMIN_GEOGRAPHY__COMMERCIAL_REGISTRATION_ZONE, AUG_COMMON_ADMIN_GEOGRAPHY__EFFECTIVE_DATE, AUG_COMMON_ADMIN_GEOGRAPHY__EXPIRY_DATE, AUG_COMMON_ADMIN_GEOGRAPHY__REGISTRATION_ZONE, AUG_COMMON_ADMIN_GEOGRAPHY__RTO_CLUSTER_CODE) is not null then 'HUB_LOCATION|' || LOCATION_BK end"
  COMMERCIAL_REGISTRATION_ZONE: 'AUG_COMMON_ADMIN_GEOGRAPHY__COMMERCIAL_REGISTRATION_ZONE'
  EFFECTIVE_DATE: 'AUG_COMMON_ADMIN_GEOGRAPHY__EFFECTIVE_DATE'
  EXPIRY_DATE: 'AUG_COMMON_ADMIN_GEOGRAPHY__EXPIRY_DATE'
  REGISTRATION_ZONE: 'AUG_COMMON_ADMIN_GEOGRAPHY__REGISTRATION_ZONE'
  RTO_CLUSTER_CODE: 'AUG_COMMON_ADMIN_GEOGRAPHY__RTO_CLUSTER_CODE'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!stitch_motor__v07_location'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
