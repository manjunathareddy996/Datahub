{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() for HUB_LOCATION branch 'CLM_SUPPLIERS'.
-- Provenance: explicit.

{%- set yaml_metadata -%}
source_model: 'stg_partner__clm_suppliers'
hashed_columns:
  LOCATION_HKEY: 'PARENT_NK'
derived_columns:
  PARENT_BK: 'loc_code'
  PARENT_NK: "'HUB_LOCATION|' || (loc_code)"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!CLM_SUPPLIERS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
