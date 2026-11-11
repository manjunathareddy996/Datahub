-- automate_dv.stage() for SAT_PROPOSAL_DECLARATIONS, read off central view stitch_v17_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v17_policy'
hashed_columns:
  PROPOSAL_HKEY: 'PROPOSAL_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ADVERSE_HEALTH_DECLARATION_INDICATOR'
      - 'EXISTING_POLICY_INDICATOR'
      - 'MEDICAL_HISTORY_DECLARATION_INDICATOR'
derived_columns:
  PROPOSAL_NK: "case when coalesce(PROPOSAL_DECLARATIONS__ADVERSE_HEALTH_DECLARATION_INDICATOR, PROPOSAL_DECLARATIONS__EXISTING_POLICY_INDICATOR, PROPOSAL_DECLARATIONS__MEDICAL_HISTORY_DECLARATION_INDICATOR) is not null then 'HUB_PROPOSAL|' || PROPOSAL_BK end"
  ADVERSE_HEALTH_DECLARATION_INDICATOR: 'PROPOSAL_DECLARATIONS__ADVERSE_HEALTH_DECLARATION_INDICATOR'
  EXISTING_POLICY_INDICATOR: 'PROPOSAL_DECLARATIONS__EXISTING_POLICY_INDICATOR'
  MEDICAL_HISTORY_DECLARATION_INDICATOR: 'PROPOSAL_DECLARATIONS__MEDICAL_HISTORY_DECLARATION_INDICATOR'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v17_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
