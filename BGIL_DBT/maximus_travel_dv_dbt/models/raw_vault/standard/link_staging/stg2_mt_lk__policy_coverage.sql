{{ config(materialized='view', tags=['lnk_extra']) }}
-- stage() for LNK_POLICY_COVERAGE: hub HKEYs (from each hub's own NK) and the link HKEY, over lnkbk_mt_policy_coverage.
-- Link NK = 'LNK_x|' || leg business keys, hubs in canonical-sheet order.
{%- set yaml_metadata -%}
source_model: 'lnkbk_mt_policy_coverage'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  COVERAGE_HKEY: 'COVERAGE_NK'
  POLICY_COVERAGE_HKEY: 'POLICY_COVERAGE_NK'
derived_columns:
  POLICY_COVERAGE_NK: "'LNK_POLICY_COVERAGE|' || POLICY_BK || '|' || COVERAGE_BK"
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
