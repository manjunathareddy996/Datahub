{{ config(materialized='view') }}

-- PROTOTYPE (AutomateDV evaluation) -- see docs/prototype_automate_dv/README.md.
-- 1:1 stage() on top of the existing production staging model, scoped to the payee-address
-- usage only (PAYEE_ADDRESS). Note: this table also carries HOSPITAL_CITY/HOSPITAL_STATE,
-- which the mapper's v5 Subject-Attribution sheet tagged for RE-ANCHOR to a HUB_PARTY key
-- (HOSPITAL_CODE) -- a different hub than this satellite's HUB_LOCATION grain, and already
-- flagged as excluded/unresolved in MAPPER_NOTE_V5_FOLLOWUP.md. Out of scope here, not
-- silently folded in.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_tpa_claim_details_ws'
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
  ADDRESS_USAGE_TYPE: '!payee'
  SEQUENCE_CK: '!1'
  ADDRESS_LINE_1: 'PAYEE_ADDRESS'
  LOCATION_CODE_KEY: "nullif(upper(trim(coalesce(PAYEE_ADDRESS, ''))), '')"
  LOCATION_NK: "'HUB_LOCATION|' || nullif(upper(trim(coalesce(PAYEE_ADDRESS, ''))), '')"
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
