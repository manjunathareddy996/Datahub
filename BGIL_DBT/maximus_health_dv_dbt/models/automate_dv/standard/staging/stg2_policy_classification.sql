-- automate_dv.stage() for SAT_POLICY_CLASSIFICATION, read off central view stitch_v15_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v15_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CLASSIFICATION_VALUE'
      - 'CLASSIFICATION_TYPE_CK'
derived_columns:
  POLICY_NK: "case when POLICY_CLASSIFICATION__CLASSIFICATION_VALUE is not null then 'HUB_POLICY|' || POLICY_BK end"
  CLASSIFICATION_TYPE_CK: 'POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK'
  CLASSIFICATION_VALUE: 'POLICY_CLASSIFICATION__CLASSIFICATION_VALUE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v15_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
