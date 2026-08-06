{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for HUB_DOCUMENT branch 'BJAZ_HM_PREAUTH_QUERY'.
-- Not covered by a stitch for this hub -- DOCUMENT_HKEY hashed directly here,
-- namespaced ('HUB_DOCUMENT|' || raw key), same convention as every other hkey
-- in this build (see gen_common.namespaced_hash). PARENT_BK is the raw,
-- un-namespaced business key -- used as hub()'s src_nk display column, same
-- column name every stitch-stage model already exposes for this purpose.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_preauth_query'
hashed_columns:
  DOCUMENT_HKEY: 'DOCUMENT_NK'
derived_columns:
  PARENT_BK: 'omni_inward_no'
  DOCUMENT_NK: "'HUB_DOCUMENT|' || omni_inward_no"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_PREAUTH_QUERY'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
