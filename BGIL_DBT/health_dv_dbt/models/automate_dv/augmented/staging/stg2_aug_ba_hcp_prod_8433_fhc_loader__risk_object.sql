{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_RISK_OBJECT, table 'BA_HCP_PROD_8433_FHC_LOADER'.
-- 1 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BA_HCP_PROD_8433_FHC_LOADER carries a verified HUB_RISK_OBJECT key
-- (POL_SERIAL_NO, MD_SEQ_NO), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__ba_hcp_prod_8433_fhc_loader'
hashed_columns:
  RISK_OBJECT_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'MD_SPCL_CONDTN_MEMBER_LEVEL'
derived_columns:
  PARENT_BK: "nullif(trim(to_varchar(pol_serial_no)), '') || '|' || nullif(trim(to_varchar(md_seq_no)), '')"
  PARENT_NK: "'HUB_RISK_OBJECT|' || (nullif(trim(to_varchar(pol_serial_no)), '') || '|' || nullif(trim(to_varchar(md_seq_no)), ''))"
  MD_SPCL_CONDTN_MEMBER_LEVEL: 'md_spcl_condtn_member_level'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_HCP_PROD_8433_FHC_LOADER'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
