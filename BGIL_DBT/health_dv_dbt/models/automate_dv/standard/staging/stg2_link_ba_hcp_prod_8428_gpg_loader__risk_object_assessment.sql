{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_RISK_OBJECT_ASSESSMENT member-end 'ba_hcp_prod_8428_gpg_loader'.
-- ASSESSMENT_HKEY is hashed with the EXACT SAME formula ('HUB_ASSESSMENT|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for RISK_OBJECT_HKEY.
-- RISK_OBJECT_ASSESSMENT_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__ba_hcp_prod_8428_gpg_loader'
hashed_columns:
  ASSESSMENT_HKEY: 'ASSESSMENT_HKEY_NK'
  RISK_OBJECT_HKEY: 'RISK_OBJECT_HKEY_NK'
  RISK_OBJECT_ASSESSMENT_HKEY: 'RISK_OBJECT_ASSESSMENT_HKEY_NK'
derived_columns:
  ASSESSMENT_HKEY_NK: "'HUB_ASSESSMENT|' || pd_scrutiny_number"
  RISK_OBJECT_HKEY_NK: "'HUB_RISK_OBJECT|' || md_seq_no"
  RISK_OBJECT_ASSESSMENT_HKEY_NK: "'LNK_RISK_OBJECT_ASSESSMENT|' || pd_scrutiny_number || '|' || md_seq_no"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_HCP_PROD_8428_GPG_LOADER'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
