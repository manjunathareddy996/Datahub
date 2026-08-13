{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_AGREEMENT_CHANNEL member-end 'bjaz_health_webservice_info'.
-- AGREEMENT_HKEY is hashed with the EXACT SAME formula ('HUB_AGREEMENT|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for DISTRIBUTION_CHANNEL_HKEY.
-- AGREEMENT_CHANNEL_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_health_webservice_info'
hashed_columns:
  AGREEMENT_HKEY: 'AGREEMENT_HKEY_NK'
  DISTRIBUTION_CHANNEL_HKEY: 'DISTRIBUTION_CHANNEL_HKEY_NK'
  AGREEMENT_CHANNEL_HKEY: 'AGREEMENT_CHANNEL_HKEY_NK'
derived_columns:
  AGREEMENT_HKEY_NK: "'HUB_AGREEMENT|' || deal_id"
  DISTRIBUTION_CHANNEL_HKEY_NK: "'HUB_DISTRIBUTION_CHANNEL|' || partner_id"
  AGREEMENT_CHANNEL_HKEY_NK: "'LNK_AGREEMENT_CHANNEL|' || deal_id || '|' || partner_id"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HEALTH_WEBSERVICE_INFO'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
