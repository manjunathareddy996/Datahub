{{ config(materialized='view') }}

-- MAXIMUS PARTNER wide stage() for BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_DOCUMENT_DETAIL.
-- 1 key(s), 1 single-active satellite(s).

{%- set yaml_metadata -%}
source_model: 'stg_maximus__pd_doc'
hashed_columns:
  DOCUMENT_HKEY: 'DOCUMENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DOCUMENT_NAME'
      - 'DOCUMENT_TYPE'
      - 'ISSUE_DATE'
derived_columns:
  DOCUMENT_BK: "document_id"
  DOCUMENT_NK: "'HUB_DOCUMENT|' || (document_id)"
  ISSUE_DATE: "document_generation_date"
  DOCUMENT_NAME: "document_name"
  DOCUMENT_TYPE: "document_type"
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_DOCUMENT_DETAIL'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                     source_model=metadata_dict['source_model'],
                     hashed_columns=metadata_dict['hashed_columns'],
                     derived_columns=metadata_dict['derived_columns']) }}
