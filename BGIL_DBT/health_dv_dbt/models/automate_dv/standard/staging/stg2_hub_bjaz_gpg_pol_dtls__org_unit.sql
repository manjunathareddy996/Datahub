{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for HUB_ORG_UNIT branch 'BJAZ_GPG_POL_DTLS'.
-- Not covered by a stitch for this hub -- ORG_UNIT_HKEY hashed directly here,
-- namespaced ('HUB_ORG_UNIT|' || raw key), same convention as every other hkey
-- in this build (see gen_common.namespaced_hash). PARENT_BK is the raw,
-- un-namespaced business key -- used as hub()'s src_nk display column, same
-- column name every stitch-stage model already exposes for this purpose.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_gpg_pol_dtls'
hashed_columns:
  ORG_UNIT_HKEY: 'ORG_UNIT_NK'
derived_columns:
  PARENT_BK: 'company_org_unit'
  ORG_UNIT_NK: "'HUB_ORG_UNIT|' || company_org_unit"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_GPG_POL_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
