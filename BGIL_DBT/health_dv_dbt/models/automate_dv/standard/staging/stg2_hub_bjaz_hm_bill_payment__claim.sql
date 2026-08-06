{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for HUB_CLAIM branch 'BJAZ_HM_BILL_PAYMENT'.
-- Not covered by a stitch for this hub -- CLAIM_HKEY hashed directly here,
-- namespaced ('HUB_CLAIM|' || raw key), same convention as every other hkey
-- in this build (see gen_common.namespaced_hash). PARENT_BK is the raw,
-- un-namespaced business key -- used as hub()'s src_nk display column, same
-- column name every stitch-stage model already exposes for this purpose.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_bill_payment'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
derived_columns:
  PARENT_BK: 'claim_id'
  CLAIM_NK: "'HUB_CLAIM|' || claim_id"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_BILL_PAYMENT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
