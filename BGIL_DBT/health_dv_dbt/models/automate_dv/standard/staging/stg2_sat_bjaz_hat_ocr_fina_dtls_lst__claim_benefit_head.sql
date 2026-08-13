{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_CLAIM_BENEFIT_HEAD, table 'BJAZ_HAT_OCR_FINA_DTLS_LST' (union branch, no attribute-level merge needed).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hat_ocr_fina_dtls_lst'
hashed_columns:
  CLAIM_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CLAIMED_AMOUNT'
derived_columns:
  PARENT_BK: 'case_id'
  PARENT_NK: "'HUB_CLAIM|' || (case_id)"
  BENEFIT_HEAD_CODE_CK: '!'
  CLAIMED_AMOUNT: 'total'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HAT_OCR_FINA_DTLS_LST'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
