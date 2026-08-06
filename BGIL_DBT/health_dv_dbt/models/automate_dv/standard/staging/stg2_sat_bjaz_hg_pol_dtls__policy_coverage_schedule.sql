{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_POLICY_COVERAGE_SCHEDULE, table 'BJAZ_HG_POL_DTLS' (union branch, no attribute-level merge needed).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hg_pol_dtls'
hashed_columns:
  POLICY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COVERAGE_OPTED_INDICATOR'
derived_columns:
  PARENT_BK: 'contract_id'
  PARENT_NK: "'HUB_POLICY|' || (contract_id)"
  COVERAGE_REFERENCE_CK: '!'
  COVERAGE_SEQUENCE_CK: '!'
  COVERAGE_OPTED_INDICATOR: 'air_ambulance_yn'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HG_POL_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
