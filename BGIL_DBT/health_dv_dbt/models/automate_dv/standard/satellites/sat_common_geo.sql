{{ config(materialized='incremental') }}

-- STANDARD-MODEL sat() for SAT_COMMON_GEO (HUB_LOCATION grain) -- single contributing table.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_sat_bjaz_hm_inward_dtls__common_geo'
src_pk: 'LOCATION_HK'
src_payload:
  - 'REGION_NAME'
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
