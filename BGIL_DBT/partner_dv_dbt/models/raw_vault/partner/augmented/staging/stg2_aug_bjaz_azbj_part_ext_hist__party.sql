{{ config(materialized='view') }}

-- PARTNER AUGMENTED (unconfirmed) per-table stage() for HUB_PARTY, table 'BJAZ_AZBJ_PART_EXT_HIST'.
-- 3 previously-unmapped column(s), per the modeler's own
-- Augmentation sheet -- NOT yet formally added to data_5a.js. BJAZ_AZBJ_PART_EXT_HIST carries a
-- verified HUB_PARTY key, so the key itself is genuine; the attribute proposal is not
-- yet mapper-confirmed as a model change.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_azbj_part_ext_hist'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ECS_MANDATE_STATUS'
      - 'IT_STATUS'
      - 'PARENT_ENTITY_REFERENCE'
derived_columns:
  PARENT_BK: 'part_id'
  PARENT_NK: "'HUB_PARTY|' || (part_id)"
  ECS_MANDATE_STATUS: 'ecs_status'
  IT_STATUS: 'it_status'
  PARENT_ENTITY_REFERENCE: 'parent_id'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_AZBJ_PART_EXT_HIST'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
