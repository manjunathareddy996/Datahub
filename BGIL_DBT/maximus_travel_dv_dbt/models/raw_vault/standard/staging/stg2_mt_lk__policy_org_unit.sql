{{ config(materialized='view') }}
-- stage() for LNK_POLICY_ORG_UNIT: hub HKEYs (from each hub's own NK) and the link HKEY, over lnkbk_mt_policy_org_unit.
-- Link NK = 'LNK_x|' || leg business keys, hubs in canonical-sheet order.
{%- set yaml_metadata -%}
source_model: 'lnkbk_mt_policy_org_unit'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  ORG_UNIT_HKEY: 'ORG_UNIT_NK'
  POLICY_ORG_UNIT_HKEY: 'POLICY_ORG_UNIT_NK'
derived_columns:
  POLICY_ORG_UNIT_NK: "'LNK_POLICY_ORG_UNIT|' || POLICY_BK || '|' || ORG_UNIT_BK"
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
