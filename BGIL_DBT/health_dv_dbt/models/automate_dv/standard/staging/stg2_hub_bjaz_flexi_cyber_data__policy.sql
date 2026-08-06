{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for HUB_POLICY branch 'BJAZ_FLEXI_CYBER_DATA'.
-- Not covered by a stitch for this hub -- POLICY_HKEY hashed directly here,
-- namespaced ('HUB_POLICY|' || raw key), same convention as every other hkey
-- in this build (see gen_common.namespaced_hash). PARENT_BK is the raw,
-- un-namespaced business key -- used as hub()'s src_nk display column, same
-- column name every stitch-stage model already exposes for this purpose.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_flexi_cyber_data'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
derived_columns:
  PARENT_BK: 'master_policy_no'
  POLICY_NK: "'HUB_POLICY|' || master_policy_no"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_FLEXI_CYBER_DATA'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
