{{ config(materialized='view') }}
-- TRAVEL STANDARD-MODEL stage() for LNK_POLICY_ORG_UNIT: hub keys and the link key, hashed off stitch_travel__lnk_policy_org_unit.
-- Link NK = 'LNK_x|' || leg business keys in alphabetical hub order (same convention as Motor/Health).
{%- set yaml_metadata -%}
source_model: 'stitch_travel__lnk_policy_org_unit'
hashed_columns:
  ORG_UNIT_HKEY: 'ORG_UNIT_NK'
  POLICY_HKEY: 'POLICY_NK'
  POLICY_ORG_UNIT_HKEY: 'POLICY_ORG_UNIT_NK'
derived_columns:
  ORG_UNIT_NK: "'HUB_ORG_UNIT|' || ORG_UNIT_BK"
  POLICY_NK: "'HUB_POLICY|' || POLICY_BK"
  POLICY_ORG_UNIT_NK: "'LNK_POLICY_ORG_UNIT|' || ORG_UNIT_BK || '|' || POLICY_BK"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: 'RECORD_SRC'
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
