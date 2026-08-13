{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_RISK_OBJECT, table 'BJAZ_EC_MEM_DTLS_EXTN'.
-- 1 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BJAZ_EC_MEM_DTLS_EXTN carries a verified HUB_RISK_OBJECT key
-- (CONTRACT_ID, MEMBER_NO), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_ec_mem_dtls_extn'
hashed_columns:
  RISK_OBJECT_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'FMLY_HLTH_COMPLAINS'
derived_columns:
  PARENT_BK: "nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), '')"
  PARENT_NK: "'HUB_RISK_OBJECT|' || (nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), ''))"
  FMLY_HLTH_COMPLAINS: 'fmly_hlth_complains'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_EC_MEM_DTLS_EXTN'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
