-- automate_dv.stage() for SAT_POLICY_FLEET, read off central view stitch_motor__v19_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v19_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'NAMED_DRIVER_POLICY_INDICATOR'
derived_columns:
  POLICY_NK: "case when POLICY_FLEET__NAMED_DRIVER_POLICY_INDICATOR is not null then 'HUB_POLICY|' || POLICY_BK end"
  NAMED_DRIVER_POLICY_INDICATOR: 'POLICY_FLEET__NAMED_DRIVER_POLICY_INDICATOR'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!stitch_motor__v19_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
