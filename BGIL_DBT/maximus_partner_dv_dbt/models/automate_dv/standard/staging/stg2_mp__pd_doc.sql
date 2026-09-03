{{ config(materialized='view') }}

-- MAXIMUS PARTNER wide stage() for BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_DOCUMENT_DETAIL.
-- 1 key(s), 1 single-active satellite(s).

{%- set yaml_metadata -%}
source_model: 'stg_maximus__pd_doc'
hashed_columns:
  DOCUMENT_HKEY: 'DOCUMENT_NK'
  HASHDIFF_DOCUMENT_DEFINITION:
    is_hashdiff: true
    columns:
      - 'DOCUMENTNAME'
      - 'DOCUMENTTYPE'
      - 'ISSUEDATE'
derived_columns:
  DOCUMENT_BK: "document_id"
  DOCUMENT_NK: "'HUB_DOCUMENT|' || (document_id)"
  ISSUEDATE: "document_generation_date"
  DOCUMENTNAME: "document_name"
  DOCUMENTTYPE: "document_type"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_DOCUMENT_DETAIL'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                     source_model=metadata_dict['source_model'],
                     hashed_columns=metadata_dict['hashed_columns'],
                     derived_columns=metadata_dict['derived_columns']) }}
