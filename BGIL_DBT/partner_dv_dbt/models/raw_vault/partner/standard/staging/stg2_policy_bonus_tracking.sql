{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL stage() pass for stitch_policy_bonus_tracking -- serves SAT_POLICY_BONUS_TRACKING.
-- POLICY_HKEY hashed once here (namespaced: 'HUB_POLICY|' || raw key).

{%- set yaml_metadata -%}
source_model: 'stitch_policy_bonus_tracking'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BONUSAMOUNT'
      - 'CUMULATIVEBONUSPERCENTAGE'
derived_columns:
  POLICY_NK: "'HUB_POLICY|' || PARENT_BK"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
