{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_PARTY_CORRESPONDENCE, table 'BJAZ_HM_OUTWARD_DTLS' (single contributing table).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_outward_dtls'
hashed_columns:
  CLAIM_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CHANNEL'
derived_columns:
  PARENT_BK: 'claim_id'
  PARENT_NK: "'HUB_CLAIM|' || (claim_id)"
  DISPATCH_REFERENCE_CK: '!'
  CHANNEL: 'mode_of_dispatch'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_OUTWARD_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
