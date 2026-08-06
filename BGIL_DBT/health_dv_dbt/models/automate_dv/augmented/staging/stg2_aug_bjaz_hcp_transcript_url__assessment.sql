{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_ASSESSMENT, table 'BJAZ_HCP_TRANSCRIPT_URL'.
-- 1 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BJAZ_HCP_TRANSCRIPT_URL carries a verified HUB_ASSESSMENT key
-- (SCRUTINY_NO), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hcp_transcript_url'
hashed_columns:
  ASSESSMENT_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'V_SECOND_SCR'
derived_columns:
  PARENT_BK: 'scrutiny_no'
  PARENT_NK: "'HUB_ASSESSMENT|' || (scrutiny_no)"
  V_SECOND_SCR: 'v_second_scr'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HCP_TRANSCRIPT_URL'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
