{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for the M4 party-address route.
-- Table 'BJAZ_TPA_CLAIM_DETAILS_WS', usage = 'payee' (PAYEE_ADDRESS only mapper-confirmed).
-- Column names match lnk_party_location.sql's existing convention.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_tpa_claim_details_ws'
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
  LOCATION_CODE_KEY: "nullif(upper(trim(coalesce(PAYEE_ADDRESS, ''))), '')"
  LOCATION_HKEY_NK: "'HUB_LOCATION|' || nullif(upper(trim(coalesce(PAYEE_ADDRESS, ''))), '')"
  PARTY_LOCATION_HKEY_NK: "'LNK_PARTY_LOCATION|' || CUSTOMER_ID || '|' || nullif(upper(trim(coalesce(PAYEE_ADDRESS, ''))), '')"
  ADDRESS_USAGE_TYPE: '!payee'
  ADDRESS_LINE_1: 'PAYEE_ADDRESS'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_TPA_CLAIM_DETAILS_WS'
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
