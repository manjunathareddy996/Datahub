{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for HUB_ORG_UNIT branch 'BA_HCP_PROD_8439_CLH_LOADER'.
-- Not covered by a stitch for this hub -- ORG_UNIT_HKEY hashed directly here,
-- namespaced ('HUB_ORG_UNIT|' || raw key), same convention as every other hkey
-- in this build (see gen_common.namespaced_hash). PARENT_BK is the raw,
-- un-namespaced business key -- used as hub()'s src_nk display column, same
-- column name every stitch-stage model already exposes for this purpose.

{%- set yaml_metadata -%}
source_model: 'stg_health__ba_hcp_prod_8439_clh_loader'
hashed_columns:
  ORG_UNIT_HKEY: 'ORG_UNIT_NK'
derived_columns:
  PARENT_BK: 'pd_location_code'
  ORG_UNIT_NK: "'HUB_ORG_UNIT|' || pd_location_code"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_HCP_PROD_8439_CLH_LOADER'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
