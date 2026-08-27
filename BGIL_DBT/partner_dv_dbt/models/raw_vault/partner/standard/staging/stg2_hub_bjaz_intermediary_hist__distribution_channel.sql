{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() for HUB_DISTRIBUTION_CHANNEL branch 'BJAZ_INTERMEDIARY_HIST'.
-- Provenance: confirmed-fallback (IRDA_INTERMEDIARY_CODE too sparse in sample data). Added by mapper feedback round 2 -- this hub previously had
-- zero verified Partner keys.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_intermediary_hist'
hashed_columns:
  DISTRIBUTION_CHANNEL_HKEY: 'PARENT_NK'
derived_columns:
  PARENT_BK: 'intermediary_id'
  PARENT_NK: "'HUB_DISTRIBUTION_CHANNEL|' || (intermediary_id)"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!BJAZ_INTERMEDIARY_HIST'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
