{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for the M4 party-address route. Table
-- 'BJAZ_BANDHAN_MEDI_CLAM', usages = 'proposer' + 'member' (via the unpivot).
-- Column names match lnk_party_location.sql's existing convention (see
-- stg2_addrusage_ba_hcp_pp_mem_dtls.sql for the full rationale).

{%- set yaml_metadata -%}
source_model: 'unpivot_bjaz_bandhan_medi_clam_addrusage'
hashed_columns:
  PARTY_HKEY: 'PARTY_HKEY_NK'
  LOCATION_HKEY: 'LOCATION_HKEY_NK'
  PARTY_LOCATION_HKEY: 'PARTY_LOCATION_HKEY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ADDRESS_USAGE_TYPE'
derived_columns:
  PARTY_BK: 'CUSTOMER_ID'
  PARTY_HKEY_NK: "'HUB_PARTY|' || CUSTOMER_ID"
  LOCATION_CODE_KEY: "nullif(upper(trim(coalesce(ADDRESS_LINE_1,''))) || '|' || upper(trim(coalesce(ADDRESS_LINE_2,''))) || '|' || upper(trim(coalesce(CITY,''))) || '|' || upper(trim(coalesce(STATE_CODE,''))) || '|' || upper(trim(coalesce(POSTAL_CODE,''))), '||||')"
  LOCATION_HKEY_NK: "'HUB_LOCATION|' || nullif(upper(trim(coalesce(ADDRESS_LINE_1,''))) || '|' || upper(trim(coalesce(ADDRESS_LINE_2,''))) || '|' || upper(trim(coalesce(CITY,''))) || '|' || upper(trim(coalesce(STATE_CODE,''))) || '|' || upper(trim(coalesce(POSTAL_CODE,''))), '||||')"
  PARTY_LOCATION_HKEY_NK: "'LNK_PARTY_LOCATION|' || CUSTOMER_ID || '|' || nullif(upper(trim(coalesce(ADDRESS_LINE_1,''))) || '|' || upper(trim(coalesce(ADDRESS_LINE_2,''))) || '|' || upper(trim(coalesce(CITY,''))) || '|' || upper(trim(coalesce(STATE_CODE,''))) || '|' || upper(trim(coalesce(POSTAL_CODE,''))), '||||')"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_BANDHAN_MEDI_CLAM'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
