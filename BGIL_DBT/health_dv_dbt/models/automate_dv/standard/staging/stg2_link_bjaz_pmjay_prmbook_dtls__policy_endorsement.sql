{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_POLICY_ENDORSEMENT member-end 'bjaz_pmjay_prmbook_dtls'.
-- POLICY_HKEY is hashed with the EXACT SAME formula ('HUB_POLICY|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for LINK_INSTANCE_HKEY.
-- POLICY_ENDORSEMENT_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_pmjay_prmbook_dtls'
hashed_columns:
  POLICY_HKEY: 'POLICY_HKEY_NK'
  LINK_INSTANCE_HKEY: 'LINK_INSTANCE_HKEY_NK'
  POLICY_ENDORSEMENT_HKEY: 'POLICY_ENDORSEMENT_HKEY_NK'
derived_columns:
  POLICY_HKEY_NK: "'HUB_POLICY|' || policy_ref"
  LINK_INSTANCE_HKEY_NK: "'LNK_POLICY_ENDORSEMENT|' || endt_no"
  POLICY_ENDORSEMENT_HKEY_NK: "'LNK_POLICY_ENDORSEMENT|' || policy_ref || '|' || endt_no"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_PMJAY_PRMBOOK_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
