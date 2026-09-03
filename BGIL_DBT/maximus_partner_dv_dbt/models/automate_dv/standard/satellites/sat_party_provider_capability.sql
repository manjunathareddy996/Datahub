{{ config(materialized='incremental') }}

-- MAXIMUS PARTNER ma_sat() for SAT_PARTY_PROVIDER_CAPABILITY.
-- Writes the SAME physical table as partner_dv_dbt's model of the same name: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY Maximus's sources and only the
-- payload Maximus populates, which is what removes any need to back-patch the other project.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_mp_up__pd_prop_sp_pv__party_provider_capability'
src_pk: 'PARTY_HKEY'
src_cdk:
  - 'FACILITYCODE'
src_payload:
  - 'ACCREDITATIONINDICATOR'
  - 'ACCREDITATIONREFERENCE'
  - 'AVAILABLEINDICATOR'
  - 'CAPABILITYREMARKS'
  - 'CAPACITY'
  - 'FACILITYCOUNT'
src_hashdiff: 'HASHDIFF_PARTY_PROVIDER_CAPABILITY'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.ma_sat(src_pk=metadata_dict['src_pk'],
                       src_cdk=metadata_dict['src_cdk'],
                       src_payload=metadata_dict['src_payload'],
                       src_hashdiff=metadata_dict['src_hashdiff'],
                       src_ldts=metadata_dict['src_ldts'],
                       src_source=metadata_dict['src_source'],
                       source_model=metadata_dict['source_model']) }}
