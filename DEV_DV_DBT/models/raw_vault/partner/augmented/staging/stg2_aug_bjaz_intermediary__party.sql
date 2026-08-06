{{ config(materialized='view') }}

-- PARTNER AUGMENTED (unconfirmed) per-table stage() for HUB_PARTY, table 'BJAZ_INTERMEDIARY'.
-- 3 previously-unmapped column(s), per the modeler's own
-- Augmentation sheet -- NOT yet formally added to data_5a.js. BJAZ_INTERMEDIARY carries a
-- verified HUB_PARTY key, so the key itself is genuine; the attribute proposal is not
-- yet mapper-confirmed as a model change.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_intermediary'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'WEBSITE_URL'
      - 'PAN_AADHAR_LINKED'
      - 'IT_RETURN_2YR'
derived_columns:
  PARENT_BK: 'intermediary_id'
  PARENT_NK: "'HUB_PARTY|' || (intermediary_id)"
  WEBSITE_URL: 'website_link'
  PAN_AADHAR_LINKED: 'pan_aadhar_linked'
  IT_RETURN_2YR: 'it_return_2yr'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_INTERMEDIARY'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
