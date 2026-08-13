{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_DOCUMENT, table 'BJAZ_HM_INWARD_DTLS'.
-- 3 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BJAZ_HM_INWARD_DTLS carries a verified HUB_DOCUMENT key
-- (INWARD_ID), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_inward_dtls'
hashed_columns:
  DOCUMENT_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'POD_NO'
      - 'DOC_INW_REMARK'
      - 'DOC_REMARK'
derived_columns:
  PARENT_BK: 'inward_id'
  PARENT_NK: "'HUB_DOCUMENT|' || (inward_id)"
  POD_NO: 'pod_no'
  DOC_INW_REMARK: 'doc_inw_remark'
  DOC_REMARK: 'doc_remark'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_INWARD_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
