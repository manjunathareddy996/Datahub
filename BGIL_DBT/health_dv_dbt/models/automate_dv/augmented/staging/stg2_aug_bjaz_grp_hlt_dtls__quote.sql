{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_QUOTE, table 'BJAZ_GRP_HLT_DTLS'.
-- 6 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BJAZ_GRP_HLT_DTLS carries a verified HUB_QUOTE key
-- (QUOTE_SUB_NO), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_grp_hlt_dtls'
hashed_columns:
  QUOTE_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PRIORITY'
      - 'RESOLUTION_DATE'
      - 'QUOTE_SUB_STATUS'
      - 'QUOTE_SUB_STATUS_DESC'
      - 'DATA_INFORMATION'
      - 'LAST_QUOTE_SUB_DATE'
derived_columns:
  PARENT_BK: 'quote_sub_no'
  PARENT_NK: "'HUB_QUOTE|' || (quote_sub_no)"
  PRIORITY: 'priority'
  RESOLUTION_DATE: 'resolution_date'
  QUOTE_SUB_STATUS: 'quote_sub_status'
  QUOTE_SUB_STATUS_DESC: 'quote_sub_status_desc'
  DATA_INFORMATION: 'data_information'
  LAST_QUOTE_SUB_DATE: 'last_quote_sub_date'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_GRP_HLT_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
