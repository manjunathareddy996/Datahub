{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_PROPOSAL_UNDERWRITING, table 'BJAZ_GRP_HLT_DTLS' (single contributing table).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_grp_hlt_dtls'
hashed_columns:
  PROPOSAL_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'MEDICAL_REQUIRED_INDICATOR'
derived_columns:
  PARENT_BK: 'quote_ref_no'
  PARENT_NK: "'HUB_PROPOSAL|' || (quote_ref_no)"
  MEDICAL_REQUIRED_INDICATOR: 'nme_waiver'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_GRP_HLT_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
