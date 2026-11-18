{{ config(materialized='incremental') }}

-- MAXIMUS PARTNER sat() for SAT_COMMON_CONTACT.
-- Writes the SAME physical table as partner_dv_dbt's model of the same name: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY Maximus's sources and only the
-- payload Maximus populates, which is what removes any need to back-patch the other project.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_mp__pd_addr'
  - 'stg2_mp__pd_party_addr_prop_pv'
  - 'stg2_mp__pd_prop_msdp_pv'
  - 'stg2_mp__pd_prop_sp_pv'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'ALTERNATE_EMAIL_ADDRESS'
  - 'ALTERNATE_MOBILE_NUMBER'
  - 'EMAIL_ADDRESS'
  - 'FAX_NUMBER'
  - 'LANDLINE_NUMBER'
  - 'MOBILE_NUMBER'
  - 'SOCIALMEDIAHANDLE'
  - 'STD_CODE'
src_hashdiff: 'HASHDIFF_COMMON_CONTACT'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  stg2_mp__pd_addr: 'MAXIMUS_PARTNER'
  stg2_mp__pd_party_addr_prop_pv: 'MAXIMUS_PARTNER'
  stg2_mp__pd_prop_msdp_pv: 'MAXIMUS_PARTNER'
  stg2_mp__pd_prop_sp_pv: 'MAXIMUS_PARTNER'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ sat_multi_source(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_hashdiff_alias='HASHDIFF',
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model'],
                    src_record_source_map=metadata_dict['src_record_source_map'],
                    src_object_columns=['MOBILE_NUMBER'],
                    src_column_map={
                        'stg2_mp__pd_addr': ['ALTERNATE_EMAIL_ADDRESS', 'EMAIL_ADDRESS', 'FAX_NUMBER', 'LANDLINE_NUMBER', 'MOBILE_NUMBER', 'STD_CODE'],
                        'stg2_mp__pd_party_addr_prop_pv': ['ALTERNATE_MOBILE_NUMBER', 'MOBILE_NUMBER', 'SOCIALMEDIAHANDLE'],
                        'stg2_mp__pd_prop_msdp_pv': ['EMAIL_ADDRESS', 'MOBILE_NUMBER'],
                        'stg2_mp__pd_prop_sp_pv': ['ALTERNATE_MOBILE_NUMBER', 'EMAIL_ADDRESS', 'LANDLINE_NUMBER', 'MOBILE_NUMBER', 'STD_CODE']
                    }) }}
