{{ config(materialized='incremental') }}

-- STANDARD-MODEL ma_sat() for SAT_PARTY_PROVIDER_CAPABILITY (HUB_PARTY grain) -- union of 4 table(s), no join needed.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_sat_bjaz_hc_part_extn__party_provider_capability'
  - 'stg2_sat_bjaz_hm_hospital_master__party_provider_capability'
  - 'stg2_sat_bjaz_hm_hospital_master_extn__party_provider_capability'
  - 'stg2_sat_bjaz_hm_hosp_master_extn1__party_provider_capability'
src_pk: 'PARTY_HK'
src_cdk:
  - 'FACILITY_CODE_CK'
src_payload:
  - 'ACCREDITATION_INDICATOR'
  - 'ACCREDITATION_REFERENCE'
  - 'AVAILABLE_INDICATOR'
  - 'CAPABILITY_REMARKS'
  - 'CAPACITY'
  - 'FACILITY_CATEGORY'
  - 'FACILITY_COUNT'
  - 'FACILITY_NAME'
src_hashdiff: 'HASHDIFF'
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
