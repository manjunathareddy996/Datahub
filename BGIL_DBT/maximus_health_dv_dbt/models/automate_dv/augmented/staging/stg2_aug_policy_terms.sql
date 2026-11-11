-- automate_dv.stage() for SAT_AUG_POLICY_TERMS, read off central view stitch_v16_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v16_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'POLICY_EXCLUSION_DESCRIPTION'
derived_columns:
  POLICY_NK: "case when AUG_POLICY_TERMS__POLICY_EXCLUSION_DESCRIPTION is not null then 'HUB_POLICY|' || POLICY_BK end"
  POLICY_EXCLUSION_DESCRIPTION: 'AUG_POLICY_TERMS__POLICY_EXCLUSION_DESCRIPTION'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v16_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
