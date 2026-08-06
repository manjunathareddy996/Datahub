{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_POLICY_COVERAGE_SCHEDULE, table 'BA_HCP_PROD_8432_ECP_LOADER' (union branch, no attribute-level merge needed).

{%- set yaml_metadata -%}
source_model: 'stg_health__ba_hcp_prod_8432_ecp_loader'
hashed_columns:
  POLICY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COVERAGE_OPTED_INDICATOR'
      - 'SUM_INSURED'
derived_columns:
  PARENT_BK: 'pol_serial_no'
  PARENT_NK: "'HUB_POLICY|' || (pol_serial_no)"
  COVERAGE_REFERENCE_CK: '!'
  COVERAGE_SEQUENCE_CK: '!'
  COVERAGE_OPTED_INDICATOR: 'plac_air_ambulance_cover'
  SUM_INSURED: 'plc_inpat_hosp_treat_si'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_HCP_PROD_8432_ECP_LOADER'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
