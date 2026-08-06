{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() for HUB_LOCATION branch 'BJAZ_CLM_SUPP_EXTN'.
-- Provenance: explicit.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_clm_supp_extn'
hashed_columns:
  LOCATION_HKEY: 'PARENT_NK'
derived_columns:
  PARENT_BK: 'location_code'
  PARENT_NK: "'HUB_LOCATION|' || (location_code)"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_CLM_SUPP_EXTN'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
