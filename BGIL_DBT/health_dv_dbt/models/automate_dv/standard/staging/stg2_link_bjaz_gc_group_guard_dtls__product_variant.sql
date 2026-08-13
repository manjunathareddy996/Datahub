{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_PRODUCT_VARIANT member-end 'bjaz_gc_group_guard_dtls'.
-- PRODUCT_FROM_HKEY is hashed with the EXACT SAME formula ('HUB_PRODUCT|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for PRODUCT_TO_HKEY.
-- PRODUCT_VARIANT_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_gc_group_guard_dtls'
hashed_columns:
  PRODUCT_FROM_HKEY: 'PRODUCT_FROM_HKEY_NK'
  PRODUCT_TO_HKEY: 'PRODUCT_TO_HKEY_NK'
  PRODUCT_VARIANT_HKEY: 'PRODUCT_VARIANT_HKEY_NK'
derived_columns:
  PRODUCT_FROM_HKEY_NK: "'HUB_PRODUCT|' || plan_id"
  PRODUCT_TO_HKEY_NK: "'HUB_PRODUCT|' || product_code"
  PRODUCT_VARIANT_HKEY_NK: "'LNK_PRODUCT_VARIANT|' || plan_id || '|' || product_code"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_GC_GROUP_GUARD_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
