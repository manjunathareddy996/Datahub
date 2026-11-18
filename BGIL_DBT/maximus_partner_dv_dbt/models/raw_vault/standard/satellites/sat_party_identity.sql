{{ config(materialized='incremental') }}

-- MAXIMUS PARTNER sat() for SAT_PARTY_IDENTITY.
-- Writes the SAME physical table as partner_dv_dbt's model of the same name: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY Maximus's sources and only the
-- payload Maximus populates, which is what removes any need to back-patch the other project.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_mp__pd'
  - 'stg2_mp__pd_prop_sp_pv'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'AGE'
  - 'COUNTRY_OF_BIRTH'
  - 'COUNTRY_OF_RESIDENCE'
  - 'DATE_OF_BIRTH'
  - 'DATE_OF_DEATH'
  - 'FIRST_NAME'
  - 'GENDER_CODE'
  - 'LAST_NAME'
  - 'MIDDLE_NAME'
  - 'NATIONALITY'
  - 'PARTY_FULL_NAME'
  - 'PARTY_LEGAL_NAME'
  - 'PARTY_ORIGINATION_DATE'
  - 'PARTY_STATUS'
  - 'PARTY_SUB_TYPE_CODE'
  - 'PARTY_TYPE_CODE'
  - 'SALUTATION'
src_hashdiff: 'HASHDIFF_PARTY_IDENTITY'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  stg2_mp__pd: 'MAXIMUS_PARTNER'
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
                    src_column_map={
                        'stg2_mp__pd': ['DATE_OF_BIRTH', 'FIRST_NAME', 'GENDER_CODE', 'LAST_NAME', 'MIDDLE_NAME', 'NATIONALITY', 'PARTY_LEGAL_NAME', 'PARTY_ORIGINATION_DATE', 'PARTY_STATUS', 'PARTY_TYPE_CODE', 'SALUTATION'],
                        'stg2_mp__pd_prop_sp_pv': ['AGE', 'COUNTRY_OF_BIRTH', 'COUNTRY_OF_RESIDENCE', 'DATE_OF_BIRTH', 'DATE_OF_DEATH', 'FIRST_NAME', 'GENDER_CODE', 'LAST_NAME', 'MIDDLE_NAME', 'NATIONALITY', 'PARTY_FULL_NAME', 'PARTY_LEGAL_NAME', 'PARTY_ORIGINATION_DATE', 'PARTY_STATUS', 'PARTY_SUB_TYPE_CODE']
                    }) }}
