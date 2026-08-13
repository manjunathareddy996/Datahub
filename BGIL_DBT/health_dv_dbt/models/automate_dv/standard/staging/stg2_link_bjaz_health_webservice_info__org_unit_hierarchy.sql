{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_ORG_UNIT_HIERARCHY member-end 'bjaz_health_webservice_info'.
-- ORG_UNIT_FROM_HKEY is hashed with the EXACT SAME formula ('HUB_ORG_UNIT|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for ORG_UNIT_TO_HKEY.
-- ORG_UNIT_HIERARCHY_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_health_webservice_info'
hashed_columns:
  ORG_UNIT_FROM_HKEY: 'ORG_UNIT_FROM_HKEY_NK'
  ORG_UNIT_TO_HKEY: 'ORG_UNIT_TO_HKEY_NK'
  ORG_UNIT_HIERARCHY_HKEY: 'ORG_UNIT_HIERARCHY_HKEY_NK'
derived_columns:
  ORG_UNIT_FROM_HKEY_NK: "'HUB_ORG_UNIT|' || dept_code"
  ORG_UNIT_TO_HKEY_NK: "'HUB_ORG_UNIT|' || branch_code"
  ORG_UNIT_HIERARCHY_HKEY_NK: "'LNK_ORG_UNIT_HIERARCHY|' || dept_code || '|' || branch_code"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HEALTH_WEBSERVICE_INFO'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
