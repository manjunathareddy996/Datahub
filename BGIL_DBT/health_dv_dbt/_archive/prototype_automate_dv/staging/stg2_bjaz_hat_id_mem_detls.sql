{{ config(materialized='view') }}

-- PROTOTYPE (AutomateDV evaluation) -- see docs/prototype_automate_dv/README.md.
-- 1:1 stage() on top of the existing production staging model. Only ADDLINE1/ADDLINE2 are
-- mapper-confirmed for this table's address-usage row -- this table also has CITY/STATE/PIN
-- columns on-source that were never tagged by the mapper against this satellite; not
-- assumed here (see README "Scope, deliberately narrowed").

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hat_id_mem_detls'
hashed_columns:
  PARTY_HK: 'PARTY_NK'
  LOCATION_HK: 'LOCATION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'LOCATION_CODE_KEY'
derived_columns:
  PARTY_BK: 'MEMBER_NO'
  PARTY_NK: "'HUB_PARTY|' || MEMBER_NO"
  ADDRESS_USAGE_TYPE: '!member'
  SEQUENCE_CK: '!1'
  ADDRESS_LINE_1: 'ADDLINE1'
  ADDRESS_LINE_2: 'ADDLINE2'
  LOCATION_CODE_KEY: "nullif(upper(trim(coalesce(ADDLINE1, ''))) || '|' || upper(trim(coalesce(ADDLINE2, ''))), '|')"
  LOCATION_NK: "'HUB_LOCATION|' || nullif(upper(trim(coalesce(ADDLINE1, ''))) || '|' || upper(trim(coalesce(ADDLINE2, ''))), '|')"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HAT_ID_MEM_DETLS'
null_columns:
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
