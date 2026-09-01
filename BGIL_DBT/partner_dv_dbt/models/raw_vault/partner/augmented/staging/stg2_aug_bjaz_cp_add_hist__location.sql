{{ config(materialized='view') }}

-- PARTNER AUGMENTED (unconfirmed) per-table stage() for HUB_LOCATION, table 'BJAZ_CP_ADD_HIST'.
-- 2 previously-unmapped column(s), per the modeler's own
-- Augmentation sheet -- NOT yet formally added to data_5a.js. BJAZ_CP_ADD_HIST carries a
-- verified HUB_LOCATION key, so the key itself is genuine; the attribute proposal is not
-- yet mapper-confirmed as a model change.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_cp_add_hist'
hashed_columns:
  LOCATION_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ADDRESS_LINE4'
      - 'ADDRESS_LINE5'
derived_columns:
  PARENT_BK: 'add_id'
  PARENT_NK: "'HUB_LOCATION|' || (add_id)"
  ADDRESS_LINE4: 'address_line4'
  ADDRESS_LINE5: 'address_line5'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!BJAZ_CP_ADD_HIST'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
