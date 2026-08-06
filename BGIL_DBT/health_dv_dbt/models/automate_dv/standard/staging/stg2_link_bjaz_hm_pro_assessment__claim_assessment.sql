{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_CLAIM_ASSESSMENT member-end 'bjaz_hm_pro_assessment'.
-- ASSESSMENT_HKEY is hashed with the EXACT SAME formula ('HUB_ASSESSMENT|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for CLAIM_HKEY.
-- CLAIM_ASSESSMENT_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_pro_assessment'
hashed_columns:
  ASSESSMENT_HKEY: 'ASSESSMENT_HKEY_NK'
  CLAIM_HKEY: 'CLAIM_HKEY_NK'
  CLAIM_ASSESSMENT_HKEY: 'CLAIM_ASSESSMENT_HKEY_NK'
derived_columns:
  ASSESSMENT_HKEY_NK: "'HUB_ASSESSMENT|' || assess_id"
  CLAIM_HKEY_NK: "'HUB_CLAIM|' || claim_id"
  CLAIM_ASSESSMENT_HKEY_NK: "'LNK_CLAIM_ASSESSMENT|' || assess_id || '|' || claim_id"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_PRO_ASSESSMENT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
