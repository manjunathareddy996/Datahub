{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() for HUB_DISTRIBUTION_CHANNEL branch 'BJAZ_CLM_SUPP_EXTN'.
-- Provenance: confirmed. Added by mapper feedback round 2 -- this hub previously had
-- zero verified Partner keys.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_clm_supp_extn'
hashed_columns:
  DISTRIBUTION_CHANNEL_HKEY: 'PARENT_NK'
derived_columns:
  PARENT_BK: 'imd_code'
  PARENT_NK: "'HUB_DISTRIBUTION_CHANNEL|' || (imd_code)"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!BJAZ_CLM_SUPP_EXTN'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
