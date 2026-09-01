{{ config(materialized='view') }}

-- PARTNER AUGMENTED (unconfirmed) per-table stage() for HUB_DISTRIBUTION_CHANNEL,
-- table 'BJAZ_INTERMEDIARY'.
-- Newly unblocked by mapper feedback round 2 -- HUB_DISTRIBUTION_CHANNEL previously had
-- zero verified Partner keys; key is INTERMEDIARY_ID (fallback to INTERMEDIARY_ID, mapper-confirmed sparse alternative).

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_intermediary'
hashed_columns:
  DISTRIBUTION_CHANNEL_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'SPECIAL_INTERMEDIARY_CODE'
      - 'SUBIMD_YN'
      - 'REVISED_CHANNEL_CODE'
      - 'NEW_IMD_TYPE'
      - 'BLOCKED_FOR_RECEIPT_INDICATOR'
      - 'GREEN_CHANNEL_INDICATOR'
      - 'IMDFLAG'
      - 'FINANCE_SUB_CHANNEL_CODE'
derived_columns:
  PARENT_BK: 'intermediary_id'
  PARENT_NK: "'HUB_DISTRIBUTION_CHANNEL|' || (intermediary_id)"
  SPECIAL_INTERMEDIARY_CODE: 'spl_inter_code'
  SUBIMD_YN: 'subimd_yn'
  REVISED_CHANNEL_CODE: 'new_bc'
  NEW_IMD_TYPE: 'new_imd_type'
  BLOCKED_FOR_RECEIPT_INDICATOR: 'block_for_receipt'
  GREEN_CHANNEL_INDICATOR: 'green_channel_imd'
  IMDFLAG: 'imdflag'
  FINANCE_SUB_CHANNEL_CODE: 'fin_sub_channel_code'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!BJAZ_INTERMEDIARY'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
