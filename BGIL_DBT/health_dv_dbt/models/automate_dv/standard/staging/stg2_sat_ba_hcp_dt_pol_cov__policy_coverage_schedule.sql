{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_POLICY_COVERAGE_SCHEDULE, table 'BA_HCP_DT_POL_COV' (union branch, no attribute-level merge needed).

{%- set yaml_metadata -%}
source_model: 'stg_health__ba_hcp_dt_pol_cov'
hashed_columns:
  POLICY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PREMIUM_FOR_COVERAGE'
derived_columns:
  PARENT_BK: 'contract_id'
  PARENT_NK: "'HUB_POLICY|' || (contract_id)"
  COVERAGE_REFERENCE_CK: '!'
  COVERAGE_SEQUENCE_CK: '!'
  PREMIUM_FOR_COVERAGE: 'prem_base_cover'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_HCP_DT_POL_COV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
