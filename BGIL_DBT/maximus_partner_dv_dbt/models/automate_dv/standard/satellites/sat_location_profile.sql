{{ config(materialized='incremental') }}

-- MAXIMUS PARTNER sat() for SAT_LOCATION_PROFILE.
-- Writes the SAME physical table as partner_dv_dbt's model of the same name: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY Maximus's sources and only the
-- payload Maximus populates, which is what removes any need to back-patch the other project.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_mp__pd_party_addr_prop_pv'
  - 'stg2_mp__pd_prop_sp_pv'
src_pk: 'LOCATION_HKEY'
src_payload:
  - 'LOCATIONNAME'
  - 'LOCATIONTYPE'
src_hashdiff: 'HASHDIFF_LOCATION_PROFILE'
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
