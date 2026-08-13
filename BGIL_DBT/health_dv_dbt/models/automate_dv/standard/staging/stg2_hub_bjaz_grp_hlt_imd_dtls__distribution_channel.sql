{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for HUB_DISTRIBUTION_CHANNEL branch 'BJAZ_GRP_HLT_IMD_DTLS'.
-- Not covered by a stitch for this hub -- DISTRIBUTION_CHANNEL_HKEY hashed directly here,
-- namespaced ('HUB_DISTRIBUTION_CHANNEL|' || raw key), same convention as every other hkey
-- in this build (see gen_common.namespaced_hash). PARENT_BK is the raw,
-- un-namespaced business key -- used as hub()'s src_nk display column, same
-- column name every stitch-stage model already exposes for this purpose.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_grp_hlt_imd_dtls'
hashed_columns:
  DISTRIBUTION_CHANNEL_HKEY: 'DISTRIBUTION_CHANNEL_NK'
derived_columns:
  PARENT_BK: 'imd_code'
  DISTRIBUTION_CHANNEL_NK: "'HUB_DISTRIBUTION_CHANNEL|' || imd_code"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_GRP_HLT_IMD_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
