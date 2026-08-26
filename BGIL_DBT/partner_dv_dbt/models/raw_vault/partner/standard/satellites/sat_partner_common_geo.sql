{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='HASHDIFF'
    )
}}

-- PARTNER STANDARD-MODEL sat() for SAT_COMMON_GEO (HUB_LOCATION grain) -- stitch-backed, 2 table(s).
-- Source: stg2_shared__common_admin_geography_common_geo.

{%- set yaml_metadata -%}
source_model: 'stg2_shared__common_admin_geography_common_geo'
src_pk: 'LOCATION_HKEY'
src_payload:
  - 'REGIONCODE'
  - 'REGIONNAME'
  - 'SUBZONECODE'
  - 'ZONECODE'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_extra_columns:
  - 'DBT_RUN_TS'
  - 'INC_JOB_UPDATED_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_extra_columns=metadata_dict['src_extra_columns'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
