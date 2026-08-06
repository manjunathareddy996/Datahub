{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for HUB_PRODUCT branch 'BJAZ_PC_ONLINE_POL_DTLS_MV'.
-- Not covered by a stitch for this hub -- PRODUCT_HKEY hashed directly here,
-- namespaced ('HUB_PRODUCT|' || raw key), same convention as every other hkey
-- in this build (see gen_common.namespaced_hash). PARENT_BK is the raw,
-- un-namespaced business key -- used as hub()'s src_nk display column, same
-- column name every stitch-stage model already exposes for this purpose.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_pc_online_pol_dtls_mv'
hashed_columns:
  PRODUCT_HKEY: 'PRODUCT_NK'
derived_columns:
  PARENT_BK: 'product_4digit_code'
  PRODUCT_NK: "'HUB_PRODUCT|' || product_4digit_code"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_PC_ONLINE_POL_DTLS_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
