{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() for SAT_POLICY_CERTIFICATE, table 'BA_HCP_DT_MEM'.

{%- set yaml_metadata -%}
source_model: 'stg_partner__ba_hcp_dt_mem'
hashed_columns:
  POLICY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'MEMBERSTATUS'
derived_columns:
  PARENT_BK: 'contract_id'
  PARENT_NK: "'HUB_POLICY|' || (contract_id)"
  MEMBERSTATUS: 'mem_status'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_HCP_DT_MEM'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
