{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_PRODUCT, table 'BJAZ_CTNGY_SCHEME_MST'.
-- 4 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BJAZ_CTNGY_SCHEME_MST carries a verified HUB_PRODUCT key
-- (SCHEME_CODE), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_ctngy_scheme_mst'
hashed_columns:
  PRODUCT_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'FF_DTLS_ONLY'
      - 'NO_OF_MEMBERS'
      - 'AUTO_RENEWAL'
      - 'PARENT_FLAG'
derived_columns:
  PARENT_BK: 'scheme_code'
  PARENT_NK: "'HUB_PRODUCT|' || (scheme_code)"
  FF_DTLS_ONLY: 'ff_dtls_only'
  NO_OF_MEMBERS: 'no_of_members'
  AUTO_RENEWAL: 'auto_renewal'
  PARENT_FLAG: 'parent_flag'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_CTNGY_SCHEME_MST'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
