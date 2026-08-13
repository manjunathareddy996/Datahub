{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_ORG_UNIT_HIERARCHY member-end 'bjaz_pc_online_pol_dtls_mv'.
-- ORG_UNIT_FROM_HKEY is hashed with the EXACT SAME formula ('HUB_ORG_UNIT|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for ORG_UNIT_TO_HKEY.
-- ORG_UNIT_HIERARCHY_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_pc_online_pol_dtls_mv'
hashed_columns:
  ORG_UNIT_FROM_HKEY: 'ORG_UNIT_FROM_HKEY_NK'
  ORG_UNIT_TO_HKEY: 'ORG_UNIT_TO_HKEY_NK'
  ORG_UNIT_HIERARCHY_HKEY: 'ORG_UNIT_HIERARCHY_HKEY_NK'
derived_columns:
  ORG_UNIT_FROM_HKEY_NK: "'HUB_ORG_UNIT|' || company_org_unit"
  ORG_UNIT_TO_HKEY_NK: "'HUB_ORG_UNIT|' || department_code"
  ORG_UNIT_HIERARCHY_HKEY_NK: "'LNK_ORG_UNIT_HIERARCHY|' || company_org_unit || '|' || department_code"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_PC_ONLINE_POL_DTLS_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
