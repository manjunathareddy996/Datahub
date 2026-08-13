{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_POLICY_TENURE_SCHEDULE, table 'BJAZ_EHH_POL_DTLS' (single contributing table).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_ehh_pol_dtls'
hashed_columns:
  POLICY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'TENURE_PREMIUM'
derived_columns:
  PARENT_BK: 'policy_ref'
  PARENT_NK: "'HUB_POLICY|' || (policy_ref)"
  TENURE_SEQUENCE_CK: '!'
  TENURE_PREMIUM: 'gross_premium1'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_EHH_POL_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
