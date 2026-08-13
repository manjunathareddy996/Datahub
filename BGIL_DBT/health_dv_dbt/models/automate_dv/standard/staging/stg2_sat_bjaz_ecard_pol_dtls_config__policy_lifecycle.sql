{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_POLICY_LIFECYCLE, table 'BJAZ_ECARD_POL_DTLS_CONFIG' (single contributing table).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_ecard_pol_dtls_config'
hashed_columns:
  POLICY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'TERMINATION_DATE'
derived_columns:
  PARENT_BK: 'policy_ref'
  PARENT_NK: "'HUB_POLICY|' || (policy_ref)"
  TERMINATION_DATE: 'deactive_pol_date'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_ECARD_POL_DTLS_CONFIG'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
