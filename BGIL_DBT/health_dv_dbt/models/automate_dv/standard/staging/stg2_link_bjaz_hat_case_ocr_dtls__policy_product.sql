{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_POLICY_PRODUCT member-end 'bjaz_hat_case_ocr_dtls'.
-- POLICY_HKEY is hashed with the EXACT SAME formula ('HUB_POLICY|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for PRODUCT_HKEY.
-- POLICY_PRODUCT_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hat_case_ocr_dtls'
hashed_columns:
  POLICY_HKEY: 'POLICY_HKEY_NK'
  PRODUCT_HKEY: 'PRODUCT_HKEY_NK'
  POLICY_PRODUCT_HKEY: 'POLICY_PRODUCT_HKEY_NK'
derived_columns:
  POLICY_HKEY_NK: "'HUB_POLICY|' || policy_number"
  PRODUCT_HKEY_NK: "'HUB_PRODUCT|' || product_code"
  POLICY_PRODUCT_HKEY_NK: "'LNK_POLICY_PRODUCT|' || policy_number || '|' || product_code"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HAT_CASE_OCR_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
