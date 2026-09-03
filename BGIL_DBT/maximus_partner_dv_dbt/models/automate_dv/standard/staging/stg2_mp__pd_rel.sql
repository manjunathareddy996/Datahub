{{ config(materialized='view') }}

-- MAXIMUS PARTNER wide stage() for BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_RELATION.
-- 1 key(s), 0 single-active satellite(s).

{%- set yaml_metadata -%}
source_model: 'stg_maximus__pd_rel'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
derived_columns:
  PARTY_BK: "foreign_key"
  PARTY_NK: "'HUB_PARTY|' || (foreign_key)"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_RELATION'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                     source_model=metadata_dict['source_model'],
                     hashed_columns=metadata_dict['hashed_columns'],
                     derived_columns=metadata_dict['derived_columns']) }}
