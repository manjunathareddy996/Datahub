{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for HUB_PROPOSAL branch 'BA_HDFC_LEAD'.
-- Not covered by a stitch for this hub -- PROPOSAL_HKEY hashed directly here,
-- namespaced ('HUB_PROPOSAL|' || raw key), same convention as every other hkey
-- in this build (see gen_common.namespaced_hash). PARENT_BK is the raw,
-- un-namespaced business key -- used as hub()'s src_nk display column, same
-- column name every stitch-stage model already exposes for this purpose.

{%- set yaml_metadata -%}
source_model: 'stg_health__ba_hdfc_lead'
hashed_columns:
  PROPOSAL_HKEY: 'PROPOSAL_NK'
derived_columns:
  PARENT_BK: 'ba_lead_no'
  PROPOSAL_NK: "'HUB_PROPOSAL|' || ba_lead_no"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_HDFC_LEAD'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
