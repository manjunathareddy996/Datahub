{{ config(materialized='view') }}

-- PARTNER AUGMENTED (unconfirmed) per-table stage() for HUB_DISTRIBUTION_CHANNEL,
-- table 'BJAZ_CLM_SUPP_EXTN'.
-- Newly unblocked by mapper feedback round 2 -- HUB_DISTRIBUTION_CHANNEL previously had
-- zero verified Partner keys; key is IMD_CODE (mapper-confirmed).

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_clm_supp_extn'
hashed_columns:
  DISTRIBUTION_CHANNEL_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'SUB_IMD_CODE'
derived_columns:
  PARENT_BK: 'imd_code'
  PARENT_NK: "'HUB_DISTRIBUTION_CHANNEL|' || (imd_code)"
  SUB_IMD_CODE: 'sub_imd_code'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_CLM_SUPP_EXTN'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
