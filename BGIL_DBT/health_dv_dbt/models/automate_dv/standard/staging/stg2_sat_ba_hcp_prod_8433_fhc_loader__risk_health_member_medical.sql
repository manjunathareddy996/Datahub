{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_RISK_HEALTH_MEMBER_MEDICAL, table 'BA_HCP_PROD_8433_FHC_LOADER' (union branch, no attribute-level merge needed).

{%- set yaml_metadata -%}
source_model: 'stg_health__ba_hcp_prod_8433_fhc_loader'
hashed_columns:
  RISK_OBJECT_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DISCLOSED_INDICATOR'
derived_columns:
  PARENT_BK: "nullif(trim(to_varchar(pol_serial_no)), '') || '|' || nullif(trim(to_varchar(md_seq_no)), '')"
  PARENT_NK: "'HUB_RISK_OBJECT|' || (nullif(trim(to_varchar(pol_serial_no)), '') || '|' || nullif(trim(to_varchar(md_seq_no)), ''))"
  MEMBER_REFERENCE_CK: '!'
  DISCLOSED_INDICATOR: 'md_asthma'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_HCP_PROD_8433_FHC_LOADER'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
