-- Standard sat() for SAT_COMMON_GEO (parent HUB_LOCATION, history SCD2), fed whole from central view stitch_v10_party.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_common_geo'
src_pk: 'LOCATION_HKEY'
src_payload:
  - 'REGION_NAME'
  - 'URBAN_RURAL_CLASSIFICATION'
  - 'ZONE_CODE'
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
