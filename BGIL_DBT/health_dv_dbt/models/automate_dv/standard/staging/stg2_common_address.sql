{{ config(materialized='view') }}

-- STANDARD-MODEL stage() pass for stitch_common_address -- serves SAT_COMMON_ADDRESS.
-- The ONE place LOCATION_HK gets hashed for this cluster (namespaced: 'HUB_LOCATION|' || raw key,
-- same collision-prevention convention as the rest of this build -- see gen_common.namespaced_hash).

{%- set yaml_metadata -%}
source_model: 'stitch_common_address'
hashed_columns:
  LOCATION_HKEY: 'LOCATION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ADDRESS_LINE_1'
      - 'ADDRESS_LINE_2'
      - 'BUILDING_NAME'
      - 'CITY'
      - 'COUNTRY_CODE'
      - 'COUNTRY_NAME'
      - 'LANDMARK'
      - 'LOCALITY'
      - 'POST_OFFICE_NAME'
      - 'POSTAL_CODE'
      - 'STATE_NAME'
      - 'STREET_NAME'
      - 'VILLAGE'
derived_columns:
  LOCATION_NK: "'HUB_LOCATION|' || PARENT_BK"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
