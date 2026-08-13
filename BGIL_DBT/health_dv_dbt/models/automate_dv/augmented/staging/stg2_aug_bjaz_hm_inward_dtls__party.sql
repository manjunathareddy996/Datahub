{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_PARTY, table 'BJAZ_HM_INWARD_DTLS'.
-- 3 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BJAZ_HM_INWARD_DTLS carries a verified HUB_PARTY key
-- (COURIER_ID), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_inward_dtls'
hashed_columns:
  PARTY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PRIORITY_FLAG'
      - 'HOSP_PRIORITY_FLAG'
      - 'HOSP_PORTAL_FLAG'
derived_columns:
  PARENT_BK: 'courier_id'
  PARENT_NK: "'HUB_PARTY|' || (courier_id)"
  PRIORITY_FLAG: 'priority_flag'
  HOSP_PRIORITY_FLAG: 'hosp_priority_flag'
  HOSP_PORTAL_FLAG: 'hosp_portal_flag'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_INWARD_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
