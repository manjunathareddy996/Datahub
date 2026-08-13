{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_AGREEMENT_PARTY member-end 'bjaz_hm_hosp_master_extn1'.
-- AGREEMENT_HKEY is hashed with the EXACT SAME formula ('HUB_AGREEMENT|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for PARTY_HKEY.
-- AGREEMENT_PARTY_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_hosp_master_extn1'
hashed_columns:
  AGREEMENT_HKEY: 'AGREEMENT_HKEY_NK'
  PARTY_HKEY: 'PARTY_HKEY_NK'
  AGREEMENT_PARTY_HKEY: 'AGREEMENT_PARTY_HKEY_NK'
derived_columns:
  AGREEMENT_HKEY_NK: "'HUB_AGREEMENT|' || hosid"
  PARTY_HKEY_NK: "'HUB_PARTY|' || hosid"
  AGREEMENT_PARTY_HKEY_NK: "'LNK_AGREEMENT_PARTY|' || hosid || '|' || hosid"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_HOSP_MASTER_EXTN1'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
