{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_AGREEMENT_CHANNEL member-end 'bjaz_hm_hospital_master_extn'.
-- AGREEMENT_HKEY is hashed with the EXACT SAME formula ('HUB_AGREEMENT|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for DISTRIBUTION_CHANNEL_HKEY.
-- AGREEMENT_CHANNEL_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_hospital_master_extn'
hashed_columns:
  AGREEMENT_HKEY: 'AGREEMENT_HKEY_NK'
  DISTRIBUTION_CHANNEL_HKEY: 'DISTRIBUTION_CHANNEL_HKEY_NK'
  AGREEMENT_CHANNEL_HKEY: 'AGREEMENT_CHANNEL_HKEY_NK'
derived_columns:
  AGREEMENT_HKEY_NK: "'HUB_AGREEMENT|' || hosid"
  DISTRIBUTION_CHANNEL_HKEY_NK: "'HUB_DISTRIBUTION_CHANNEL|' || distribution_partner"
  AGREEMENT_CHANNEL_HKEY_NK: "'LNK_AGREEMENT_CHANNEL|' || hosid || '|' || distribution_partner"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_HOSPITAL_MASTER_EXTN'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
