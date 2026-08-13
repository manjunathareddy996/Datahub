{{ config(materialized='view') }}

-- STANDARD-MODEL stage() pass for stitch_policy_terms -- serves SAT_POLICY_TERMS.
-- The ONE place POLICY_HK gets hashed for this cluster (namespaced: 'HUB_POLICY|' || raw key,
-- same collision-prevention convention as the rest of this build -- see gen_common.namespaced_hash).

{%- set yaml_metadata -%}
source_model: 'stitch_policy_terms'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CO_PAYMENT_PERCENTAGE'
      - 'DEDUCTIBLE_TOTAL'
      - 'SPECIAL_CONDITIONS'
derived_columns:
  POLICY_NK: "'HUB_POLICY|' || PARENT_BK"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
