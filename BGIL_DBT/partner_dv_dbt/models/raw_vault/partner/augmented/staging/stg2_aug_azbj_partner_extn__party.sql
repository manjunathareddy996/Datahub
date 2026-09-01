{{ config(materialized='view') }}

-- PARTNER AUGMENTED (unconfirmed) per-table stage() for HUB_PARTY, table 'AZBJ_PARTNER_EXTN'.
-- 8 previously-unmapped column(s), per the modeler's own
-- Augmentation sheet -- NOT yet formally added to data_5a.js. AZBJ_PARTNER_EXTN carries a
-- verified HUB_PARTY key, so the key itself is genuine; the attribute proposal is not
-- yet mapper-confirmed as a model change.

{%- set yaml_metadata -%}
source_model: 'stg_partner__azbj_partner_extn'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'HNI_FLAG'
      - 'WEBSITE_URL'
      - 'ECS_MANDATE_STATUS'
      - 'NUMBER_OF_SONS'
      - 'NUMBER_OF_DAUGHTERS'
      - 'IT_STATUS'
      - 'PARENT_ENTITY_REFERENCE'
      - 'EXISTING_CUSTOMER_INDICATOR'
derived_columns:
  PARENT_BK: 'part_id'
  PARENT_NK: "'HUB_PARTY|' || (part_id)"
  HNI_FLAG: 'hni_flag'
  WEBSITE_URL: 'website'
  ECS_MANDATE_STATUS: 'ecs_status'
  NUMBER_OF_SONS: 'sons'
  NUMBER_OF_DAUGHTERS: 'daughters'
  IT_STATUS: 'it_status'
  PARENT_ENTITY_REFERENCE: 'parent_id'
  EXISTING_CUSTOMER_INDICATOR: 'existing_cust'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!AZBJ_PARTNER_EXTN'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
