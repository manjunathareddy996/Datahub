{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_CLAIM_LOCATION member-end 'bjaz_clm_wg_trans_dtls'.
-- CLAIM_HKEY is hashed with the EXACT SAME formula ('HUB_CLAIM|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for LOCATION_HKEY.
-- CLAIM_LOCATION_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_clm_wg_trans_dtls'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_HKEY_NK'
  LOCATION_HKEY: 'LOCATION_HKEY_NK'
  CLAIM_LOCATION_HKEY: 'CLAIM_LOCATION_HKEY_NK'
derived_columns:
  CLAIM_HKEY_NK: "'HUB_CLAIM|' || claim_id"
  LOCATION_HKEY_NK: "'HUB_LOCATION|' || location_code"
  CLAIM_LOCATION_HKEY_NK: "'LNK_CLAIM_LOCATION|' || claim_id || '|' || location_code"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_CLM_WG_TRANS_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
