{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for HUB_LOCATION branch 'BJAZ_CLM_WG_TRANS_DTLS_HIST'.
-- Not covered by a stitch for this hub -- LOCATION_HKEY hashed directly here,
-- namespaced ('HUB_LOCATION|' || raw key), same convention as every other hkey
-- in this build (see gen_common.namespaced_hash). PARENT_BK is the raw,
-- un-namespaced business key -- used as hub()'s src_nk display column, same
-- column name every stitch-stage model already exposes for this purpose.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_clm_wg_trans_dtls_hist'
hashed_columns:
  LOCATION_HKEY: 'LOCATION_NK'
derived_columns:
  PARENT_BK: 'location_code'
  LOCATION_NK: "'HUB_LOCATION|' || location_code"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_CLM_WG_TRANS_DTLS_HIST'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
