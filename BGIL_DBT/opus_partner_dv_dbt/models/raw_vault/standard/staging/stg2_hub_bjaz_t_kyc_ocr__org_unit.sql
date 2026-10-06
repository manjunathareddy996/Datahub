{{ config(materialized='view') }}

-- PARTNER+KYC per-table stage() for HUB_ORG_UNIT, branch 'BJAZ_T_KYC_OCR'.
-- Business key verbatim from the map; identifiers localised to the staging aliases.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_t_kyc_ocr'
hashed_columns:
  ORG_UNIT_HKEY: 'PARENT_NK'
derived_columns:
  PARENT_BK: "trim(business_unit)"
  PARENT_NK: "'HUB_ORG_UNIT|' || (trim(business_unit))"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_BJAZ_T_KYC_OCR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
