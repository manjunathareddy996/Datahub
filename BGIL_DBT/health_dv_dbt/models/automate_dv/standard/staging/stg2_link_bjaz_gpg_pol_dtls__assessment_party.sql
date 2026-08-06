{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_ASSESSMENT_PARTY member-end 'bjaz_gpg_pol_dtls'.
-- ASSESSMENT_HKEY is hashed with the EXACT SAME formula ('HUB_ASSESSMENT|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for PARTY_HKEY.
-- ASSESSMENT_PARTY_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_gpg_pol_dtls'
hashed_columns:
  ASSESSMENT_HKEY: 'ASSESSMENT_HKEY_NK'
  PARTY_HKEY: 'PARTY_HKEY_NK'
  ASSESSMENT_PARTY_HKEY: 'ASSESSMENT_PARTY_HKEY_NK'
derived_columns:
  ASSESSMENT_HKEY_NK: "'HUB_ASSESSMENT|' || scrutiny_no"
  PARTY_HKEY_NK: "'HUB_PARTY|' || bagic_e_code"
  ASSESSMENT_PARTY_HKEY_NK: "'LNK_ASSESSMENT_PARTY|' || scrutiny_no || '|' || bagic_e_code"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_GPG_POL_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
