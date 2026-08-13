{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_PRODUCT_COVERAGE member-end 'ba_hcp_dt_premium'.
-- COVERAGE_HKEY is hashed with the EXACT SAME formula ('HUB_COVERAGE|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for PRODUCT_HKEY.
-- PRODUCT_COVERAGE_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__ba_hcp_dt_premium'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_HKEY_NK'
  PRODUCT_HKEY: 'PRODUCT_HKEY_NK'
  PRODUCT_COVERAGE_HKEY: 'PRODUCT_COVERAGE_HKEY_NK'
derived_columns:
  COVERAGE_HKEY_NK: "'HUB_COVERAGE|' || hcp_seqno"
  PRODUCT_HKEY_NK: "'HUB_PRODUCT|' || product_code"
  PRODUCT_COVERAGE_HKEY_NK: "'LNK_PRODUCT_COVERAGE|' || hcp_seqno || '|' || product_code"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_HCP_DT_PREMIUM'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
