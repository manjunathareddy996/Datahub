{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_DISTRIBUTION_CHANNEL, table 'BJAZ_HDFC_SEC_FHPP'.
-- 1 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BJAZ_HDFC_SEC_FHPP carries a verified HUB_DISTRIBUTION_CHANNEL key
-- (IMD_CODE), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hdfc_sec_fhpp'
hashed_columns:
  DISTRIBUTION_CHANNEL_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BDR_CODE'
derived_columns:
  PARENT_BK: 'imd_code'
  PARENT_NK: "'HUB_DISTRIBUTION_CHANNEL|' || (imd_code)"
  BDR_CODE: 'bdr_code'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HDFC_SEC_FHPP'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
