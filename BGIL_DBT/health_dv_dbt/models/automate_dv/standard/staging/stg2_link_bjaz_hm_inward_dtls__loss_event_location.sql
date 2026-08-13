{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_LOSS_EVENT_LOCATION member-end 'bjaz_hm_inward_dtls'.
-- LOCATION_HKEY is hashed with the EXACT SAME formula ('HUB_LOCATION|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for LOSS_EVENT_HKEY.
-- LOSS_EVENT_LOCATION_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_inward_dtls'
hashed_columns:
  LOCATION_HKEY: 'LOCATION_HKEY_NK'
  LOSS_EVENT_HKEY: 'LOSS_EVENT_HKEY_NK'
  LOSS_EVENT_LOCATION_HKEY: 'LOSS_EVENT_LOCATION_HKEY_NK'
derived_columns:
  LOCATION_HKEY_NK: "'HUB_LOCATION|' || location_code"
  LOSS_EVENT_HKEY_NK: "'HUB_LOSS_EVENT|' || claim_id"
  LOSS_EVENT_LOCATION_HKEY_NK: "'LNK_LOSS_EVENT_LOCATION|' || location_code || '|' || claim_id"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_INWARD_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
