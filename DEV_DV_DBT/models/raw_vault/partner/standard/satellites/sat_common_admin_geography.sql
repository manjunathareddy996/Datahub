{{ config(materialized='incremental') }}

-- PARTNER STANDARD-MODEL sat() for SAT_COMMON_ADMIN_GEOGRAPHY (HUB_LOCATION grain) -- stitch-backed, 2 table(s).
-- Source: stg2_shared__common_admin_geography_common_geo.

{%- set yaml_metadata -%}
source_model: 'stg2_shared__common_admin_geography_common_geo'
src_pk: 'LOCATION_HKEY'
src_payload:
  - 'PINCODE'
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
