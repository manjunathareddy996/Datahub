{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_COVERAGE, table 'BJAZ_HG_POL_DTLS'.
-- 1 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BJAZ_HG_POL_DTLS carries a verified HUB_COVERAGE key
-- (COVER_CODE), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hg_pol_dtls'
hashed_columns:
  COVERAGE_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PAN_IND_COVER_YN'
derived_columns:
  PARENT_BK: 'cover_code'
  PARENT_NK: "'HUB_COVERAGE|' || (cover_code)"
  PAN_IND_COVER_YN: 'pan_ind_cover_yn'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HG_POL_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
