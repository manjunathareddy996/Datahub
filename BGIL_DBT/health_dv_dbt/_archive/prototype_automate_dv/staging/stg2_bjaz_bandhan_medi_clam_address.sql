{{ config(materialized='view') }}

-- PROTOTYPE (AutomateDV evaluation) -- see docs/prototype_automate_dv/README.md.
-- stage() on top of the single-table unpivot (still 1 logical source table -- the reshape
-- doesn't introduce a second table). include_source_columns=true is safe here because the
-- unpivot view only contains the 7 columns this satellite needs -- no unrelated columns to
-- collide with, unlike reading the full production staging model directly.

{%- set yaml_metadata -%}
source_model: 'unpivot_bjaz_bandhan_medi_clam_address'
hashed_columns:
  PARTY_HK: 'PARTY_NK'
  LOCATION_HK: 'LOCATION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'LOCATION_CODE_KEY'
derived_columns:
  PARTY_BK: 'CUSTOMER_ID'
  PARTY_NK: "'HUB_PARTY|' || CUSTOMER_ID"
  SEQUENCE_CK: '!1'
  LOCATION_CODE_KEY: "nullif(upper(trim(coalesce(ADDRESS_LINE_1,''))) || '|' || upper(trim(coalesce(ADDRESS_LINE_2,''))) || '|' || upper(trim(coalesce(CITY,''))) || '|' || upper(trim(coalesce(STATE_CODE,''))) || '|' || upper(trim(coalesce(POSTAL_CODE,''))), '||||')"
  LOCATION_NK: "'HUB_LOCATION|' || nullif(upper(trim(coalesce(ADDRESS_LINE_1,''))) || '|' || upper(trim(coalesce(ADDRESS_LINE_2,''))) || '|' || upper(trim(coalesce(CITY,''))) || '|' || upper(trim(coalesce(STATE_CODE,''))) || '|' || upper(trim(coalesce(POSTAL_CODE,''))), '||||')"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_BANDHAN_MEDI_CLAM'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
