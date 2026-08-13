{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_AGREEMENT_DOCUMENT member-end 'bjaz_remedinet_claim_details'.
-- AGREEMENT_HKEY is hashed with the EXACT SAME formula ('HUB_AGREEMENT|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for DOCUMENT_HKEY.
-- AGREEMENT_DOCUMENT_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_remedinet_claim_details'
hashed_columns:
  AGREEMENT_HKEY: 'AGREEMENT_HKEY_NK'
  DOCUMENT_HKEY: 'DOCUMENT_HKEY_NK'
  AGREEMENT_DOCUMENT_HKEY: 'AGREEMENT_DOCUMENT_HKEY_NK'
derived_columns:
  AGREEMENT_HKEY_NK: "'HUB_AGREEMENT|' || remedinet_provider_code"
  DOCUMENT_HKEY_NK: "'HUB_DOCUMENT|' || omni_inward_no"
  AGREEMENT_DOCUMENT_HKEY_NK: "'LNK_AGREEMENT_DOCUMENT|' || remedinet_provider_code || '|' || omni_inward_no"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_REMEDINET_CLAIM_DETAILS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
