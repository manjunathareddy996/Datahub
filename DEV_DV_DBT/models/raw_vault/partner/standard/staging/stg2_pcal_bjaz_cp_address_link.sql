{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() for SAT_PARTY_CONTACT_ADDRESS_LINK,
-- table 'BJAZ_CP_ADDRESS_LINK'. Reuses the SAME PARTY_HKEY/LOCATION_HKEY/
-- PARTY_LOCATION_HKEY formula as lnk_party_location.sql's own stage for this table --
-- guaranteed to match a real LNK_PARTY_LOCATION row.
-- AZBJ_ADDRESS_EXTN also carries these attributes but has no HUB_PARTY key -- excluded,
-- not force-fit (see mapper follow-up note).

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_cp_address_link'
hashed_columns:
  PARTY_LOCATION_HKEY: 'PARTY_LOCATION_HKEY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PRIMARY_ADDRESS_INDICATOR'
derived_columns:
  PARTY_LOCATION_HKEY_NK: "'LNK_PARTY_LOCATION|' || part_id || '|' || add_id"
  ADDRESS_USAGE_TYPE: 'add_type'
  PRIMARY_ADDRESS_INDICATOR: 'primary_yn'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_CP_ADDRESS_LINK'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
