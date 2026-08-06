{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() for HUB_LOCATION branch 'AZBJ_PARTNER_EXTN'.
-- Provenance: explicit.

{%- set yaml_metadata -%}
source_model: 'stg_partner__azbj_partner_extn'
hashed_columns:
  LOCATION_HKEY: 'PARENT_NK'
derived_columns:
  PARENT_BK: 'mail_add_id'
  PARENT_NK: "'HUB_LOCATION|' || (mail_add_id)"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!AZBJ_PARTNER_EXTN'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
