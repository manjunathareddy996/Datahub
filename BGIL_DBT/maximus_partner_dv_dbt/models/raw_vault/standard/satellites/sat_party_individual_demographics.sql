{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        on_schema_change='append_new_columns',
        unique_key=['PARTY_HKEY', 'HASHDIFF_PARTY_INDIVIDUAL_DEMOGRAPHICS', 'RECORD_SOURCE']
    )
}}

-- MAXIMUS PARTNER sat() for SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS.
-- Writes the SAME physical table as partner_dv_dbt's model of the same name: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY Maximus's sources and only the
-- payload Maximus populates, which is what removes any need to back-patch the other project.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_mp__pd'
  - 'stg2_mp__pd_prop_sp_pv'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'ANNUALINCOME'
  - 'DESIGNATION'
  - 'EDUCATIONALQUALIFICATION'
  - 'FATHERNAME'
  - 'HIGHESTDEGREE'
  - 'MARITALSTATUS'
  - 'OCCUPATIONCODE'
  - 'OCCUPATIONDESCRIPTION'
  - 'SPOUSENAME'
  - 'VEHICLEOWNEDINDICATOR'
  - 'YEARSINCITY'
src_hashdiff: 'HASHDIFF_PARTY_INDIVIDUAL_DEMOGRAPHICS'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  stg2_mp__pd: 'MAXIMUS'
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
                        'stg2_mp__pd': ['OCCUPATIONCODE'],
                        'stg2_mp__pd_prop_sp_pv': ['ANNUALINCOME', 'DESIGNATION', 'EDUCATIONALQUALIFICATION', 'FATHERNAME', 'HIGHESTDEGREE', 'MARITALSTATUS', 'OCCUPATIONCODE', 'OCCUPATIONDESCRIPTION', 'SPOUSENAME', 'VEHICLEOWNEDINDICATOR', 'YEARSINCITY']
                    }) }}
