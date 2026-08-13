{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_ORG_UNIT_LOCATION member-end 'bjaz_ehh_pol_dtls'.
-- LOCATION_HKEY is hashed with the EXACT SAME formula ('HUB_LOCATION|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for ORG_UNIT_HKEY.
-- ORG_UNIT_LOCATION_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_ehh_pol_dtls'
hashed_columns:
  LOCATION_HKEY: 'LOCATION_HKEY_NK'
  ORG_UNIT_HKEY: 'ORG_UNIT_HKEY_NK'
  ORG_UNIT_LOCATION_HKEY: 'ORG_UNIT_LOCATION_HKEY_NK'
derived_columns:
  LOCATION_HKEY_NK: "'HUB_LOCATION|' || risk_location"
  ORG_UNIT_HKEY_NK: "'HUB_ORG_UNIT|' || company_org_unit"
  ORG_UNIT_LOCATION_HKEY_NK: "'LNK_ORG_UNIT_LOCATION|' || risk_location || '|' || company_org_unit"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_EHH_POL_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
