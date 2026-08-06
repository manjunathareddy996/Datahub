{{ config(materialized='incremental') }}

-- STANDARD-MODEL sat() for SAT_COMMON_ADDRESS (HUB_LOCATION grain) -- stitch-backed, 6 table(s) joined.
-- Source: stg2_common_address.

{%- set yaml_metadata -%}
source_model: 'stg2_common_address'
src_pk: 'LOCATION_HKEY'
src_payload:
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
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
