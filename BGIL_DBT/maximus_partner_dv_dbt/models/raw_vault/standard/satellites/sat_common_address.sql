{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        on_schema_change='append_new_columns',
        unique_key=['LOCATION_HKEY', 'HASHDIFF_COMMON_ADDRESS', 'RECORD_SOURCE']
    )
}}

-- MAXIMUS PARTNER sat() for SAT_COMMON_ADDRESS.
-- Writes the SAME physical table as partner_dv_dbt's model of the same name: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY Maximus's sources and only the
-- payload Maximus populates, which is what removes any need to back-patch the other project.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_mp__pd_addr'
  - 'stg2_mp__pd_party_addr_prop_pv'
  - 'stg2_mp__pd_prop_sp_pv'
src_pk: 'LOCATION_HKEY'
src_payload:
  - 'ADDRESSLINE1'
  - 'ADDRESSLINE2'
  - 'ADDRESSLINE3'
  - 'CAREOFNAME'
  - 'CITY'
  - 'COUNTRYNAME'
  - 'DISTRICT'
  - 'LANDMARK'
  - 'LOCALITY'
  - 'POSTALCODE'
  - 'POSTOFFICENAME'
  - 'STATENAME'
src_hashdiff: 'HASHDIFF_COMMON_ADDRESS'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  stg2_mp__pd_addr: 'MAXIMUS'
  stg2_mp__pd_party_addr_prop_pv: 'MAXIMUS'
  stg2_mp__pd_prop_sp_pv: 'MAXIMUS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ sat_multi_source(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model'],
                    src_record_source_map=metadata_dict['src_record_source_map'],
                    src_column_map={
                        'stg2_mp__pd_addr': ['ADDRESSLINE1', 'ADDRESSLINE2', 'ADDRESSLINE3', 'CITY', 'COUNTRYNAME', 'DISTRICT', 'POSTALCODE', 'STATENAME'],
                        'stg2_mp__pd_party_addr_prop_pv': ['CITY', 'LANDMARK', 'LOCALITY', 'POSTALCODE', 'POSTOFFICENAME', 'STATENAME'],
                        'stg2_mp__pd_prop_sp_pv': ['ADDRESSLINE1', 'ADDRESSLINE2', 'ADDRESSLINE3', 'CAREOFNAME', 'CITY', 'COUNTRYNAME', 'DISTRICT', 'POSTALCODE', 'STATENAME']
                    }) }}
