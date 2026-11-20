{{ config(materialized='view') }}
-- stage() for LNK_POLICY_RISK_OBJECT: hub HKEYs (from each hub's own NK) and the link HKEY, over lnkbk_mt_policy_risk_object.
-- Link NK = 'LNK_x|' || leg business keys, hubs in canonical-sheet order.
{%- set yaml_metadata -%}
source_model: 'lnkbk_mt_policy_risk_object'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  POLICY_RISK_OBJECT_HKEY: 'POLICY_RISK_OBJECT_NK'
derived_columns:
  POLICY_RISK_OBJECT_NK: "'LNK_POLICY_RISK_OBJECT|' || POLICY_BK || '|' || RISK_OBJECT_BK"
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
