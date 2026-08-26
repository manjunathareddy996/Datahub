{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key=['PARTY_HKEY', 'HASHDIFF', 'RECORD_SOURCE']
    )
}}

-- PARTNER STANDARD-MODEL sat_multi_source() for SAT_PARTY_VEHICLE_PRIOR_INSURANCE (HUB_PARTY grain) -- 8 source table(s).

{%- set yaml_metadata -%}
source_model:
  - 'stg2_sat_bjaz_ctngy_pa_mem_dtls__party_vehicle_prior_insurance'
  - 'stg2_sat_bjaz_ec_mem_dtls_extn__party_vehicle_prior_insurance'
  - 'stg2_sat_bjaz_hcf_member_dtls__party_vehicle_prior_insurance'
  - 'stg2_sat_bjaz_hc_part_extn__party_vehicle_prior_insurance'
  - 'stg2_sat_bjaz_hlt_ensure_mem_dtls__party_vehicle_prior_insurance'
  - 'stg2_sat_bjaz_pa_detl_extn__party_vehicle_prior_insurance'
  - 'stg2_sat_bjaz_sh_mem_dtls_extn__party_vehicle_prior_insurance'
  - 'stg2_sat_bjaz_spp_member_dtls__party_vehicle_prior_insurance'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'CONTINUITYINDICATOR'
  - 'PREVIOUSEXPIRYDATE'
  - 'PREVIOUSINSURERNAME'
  - 'PREVIOUSPOLICYNUMBER'
  - 'PREVIOUSSUMINSURED'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ sat_multi_source(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
