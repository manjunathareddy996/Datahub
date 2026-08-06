{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_POLICY_CLASSIFICATION, table 'BJAZ_GPG_POL_DTLS' (union branch, no attribute-level merge needed).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_gpg_pol_dtls'
hashed_columns:
  POLICY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CLASSIFICATION_VALUE'
derived_columns:
  PARENT_BK: 'reference_id'
  PARENT_NK: "'HUB_POLICY|' || (reference_id)"
  CLASSIFICATION_TYPE_CK: '!'
  CLASSIFICATION_VALUE: 'business_type'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_GPG_POL_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
