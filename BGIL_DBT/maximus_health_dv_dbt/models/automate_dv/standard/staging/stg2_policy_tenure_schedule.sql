-- automate_dv.stage() for SAT_POLICY_TENURE_SCHEDULE, read off central view stitch_v16_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v16_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'TENURE_END_DATE'
      - 'TENURE_START_DATE'
      - 'TENURE_SEQUENCE_CK'
derived_columns:
  POLICY_NK: "case when coalesce(POLICY_TENURE_SCHEDULE__TENURE_END_DATE, POLICY_TENURE_SCHEDULE__TENURE_START_DATE) is not null then 'HUB_POLICY|' || POLICY_BK end"
  TENURE_SEQUENCE_CK: 'POLICY_TENURE_SCHEDULE__TENURE_SEQUENCE_CK'
  TENURE_END_DATE: 'POLICY_TENURE_SCHEDULE__TENURE_END_DATE'
  TENURE_START_DATE: 'POLICY_TENURE_SCHEDULE__TENURE_START_DATE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v16_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
