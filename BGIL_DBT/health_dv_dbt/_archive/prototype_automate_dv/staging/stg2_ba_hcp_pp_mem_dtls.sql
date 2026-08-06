{{ config(materialized='view') }}

-- PROTOTYPE (AutomateDV evaluation) -- see docs/prototype_automate_dv/README.md.
-- 1:1 stage() on top of the existing production staging model. Only DC_ADDRESS is mapper-
-- confirmed for this table's address-usage row -- ADDRESS_LINE_2/CITY/STATE_CODE/
-- POSTAL_CODE are genuinely absent here (null_columns), not assumed.
-- PARTY_NK/LOCATION_NK are namespaced-text helper columns (hub code + '|' + raw key),
-- hashed instead of the raw key alone -- preserves the same cross-hub collision-prevention
-- guarantee the original dbt_utils.generate_surrogate_key(["'HUB_X'", key]) pattern had;
-- AutomateDV's hashed_columns only accepts column names, not literals, so the namespacing
-- has to happen as its own derived column first. Computed from the raw source column
-- directly (not from PARTY_BK/LOCATION_CODE_KEY) to avoid relying on unverified
-- derived-column-referencing-derived-column ordering inside stage().

{%- set yaml_metadata -%}
source_model: 'stg_health__ba_hcp_pp_mem_dtls'
hashed_columns:
  PARTY_HK: 'PARTY_NK'
  LOCATION_HK: 'LOCATION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'LOCATION_CODE_KEY'
derived_columns:
  PARTY_BK: 'ALLOTED_TO'
  PARTY_NK: "'HUB_PARTY|' || ALLOTED_TO"
  ADDRESS_USAGE_TYPE: '!diagnostic-centre'
  SEQUENCE_CK: '!1'
  ADDRESS_LINE_1: 'DC_ADDRESS'
  LOCATION_CODE_KEY: "nullif(upper(trim(coalesce(DC_ADDRESS, ''))), '')"
  LOCATION_NK: "'HUB_LOCATION|' || nullif(upper(trim(coalesce(DC_ADDRESS, ''))), '')"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_HCP_PP_MEM_DTLS'
null_columns:
  - 'ADDRESS_LINE_2'
  - 'CITY'
  - 'STATE_CODE'
  - 'POSTAL_CODE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns'],
                      null_columns=metadata_dict['null_columns']) }}
