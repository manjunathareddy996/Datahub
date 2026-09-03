{{ config(materialized='view') }}

-- MAXIMUS PARTNER wide stage() for BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_RELATED_PARTY.
-- 2 key(s), 0 single-active satellite(s).

{%- set yaml_metadata -%}
source_model: 'stg_maximus__pd_relparty'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  RELATED_PARTY_HKEY: 'RELATED_PARTY_NK'
  PARTY_RELATIONSHIP_HKEY: 'PARTY_RELATIONSHIP_NK'
derived_columns:
  PARTY_BK: "foreign_key"
  PARTY_NK: "'HUB_PARTY|' || (foreign_key)"
  RELATED_PARTY_BK: "party_code"
  RELATED_PARTY_NK: "'HUB_PARTY|' || (party_code)"
  PARTY_RELATIONSHIP_BK: "(foreign_key) || '||' || (party_code)"
  PARTY_RELATIONSHIP_NK: "'LNK_PARTY_RELATIONSHIP|' || ((foreign_key) || '||' || (party_code))"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_RELATED_PARTY'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                     source_model=metadata_dict['source_model'],
                     hashed_columns=metadata_dict['hashed_columns'],
                     derived_columns=metadata_dict['derived_columns']) }}
