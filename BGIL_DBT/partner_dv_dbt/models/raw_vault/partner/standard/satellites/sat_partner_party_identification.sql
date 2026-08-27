{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key=['PARTY_HKEY', 'HASHDIFF', 'RECORD_SOURCE']
    )
}}

-- PARTNER STANDARD-MODEL sat_multi_source() for SAT_PARTY_IDENTIFICATION (HUB_PARTY grain) -- 14 source table(s).

{%- set yaml_metadata -%}
source_model:
  - 'stg2_sat_azbj_partner_extn__party_identification'
  - 'stg2_sat_bjaz_azbj_part_ext_hist__party_identification'
  - 'stg2_sat_bjaz_clm_supp_extn__party_identification'
  - 'stg2_sat_bjaz_cp_part_hist__party_identification'
  - 'stg2_sat_bjaz_ctngy_ff_dtls_extn__party_identification'
  - 'stg2_sat_bjaz_ctngy_pa_mem_dtls__party_identification'
  - 'stg2_sat_bjaz_ec_mem_dtls_extn__party_identification'
  - 'stg2_sat_bjaz_hcf_member_dtls__party_identification'
  - 'stg2_sat_bjaz_hlt_ensure_mem_dtls__party_identification'
  - 'stg2_sat_bjaz_hm_hospital_master__party_identification'
  - 'stg2_sat_bjaz_intermediary__party_identification'
  - 'stg2_sat_bjaz_intermediary_hist__party_identification'
  - 'stg2_sat_bjaz_starpkg_ff_dtls__party_identification'
  - 'stg2_sat_cp_partners__party_identification'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'AADHAARNUMBER'
  - 'AGEPROOFTYPE'
  - 'EIANUMBER'
  - 'GSTIN'
  - 'GSTREGISTRATIONSTATUS'
  - 'GSTTAXPAYERTYPE'
  - 'IDENTIFICATIONNUMBER'
  - 'PANNUMBER'
  - 'PASSPORTNUMBER'
  - 'TANNUMBER'
  - 'VATREGISTRATIONNUMBER'
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
                    source_model=metadata_dict['source_model'],
                    src_column_map={
                        'stg2_sat_azbj_partner_extn__party_identification': ['IDENTIFICATIONNUMBER', 'EIANUMBER'],
                        'stg2_sat_bjaz_azbj_part_ext_hist__party_identification': ['IDENTIFICATIONNUMBER', 'EIANUMBER'],
                        'stg2_sat_bjaz_clm_supp_extn__party_identification': ['GSTTAXPAYERTYPE', 'PANNUMBER', 'TANNUMBER'],
                        'stg2_sat_bjaz_cp_part_hist__party_identification': ['IDENTIFICATIONNUMBER', 'VATREGISTRATIONNUMBER'],
                        'stg2_sat_bjaz_ctngy_ff_dtls_extn__party_identification': ['PASSPORTNUMBER'],
                        'stg2_sat_bjaz_ctngy_pa_mem_dtls__party_identification': ['AADHAARNUMBER', 'IDENTIFICATIONNUMBER', 'PANNUMBER', 'PASSPORTNUMBER', 'EIANUMBER'],
                        'stg2_sat_bjaz_ec_mem_dtls_extn__party_identification': ['AGEPROOFTYPE'],
                        'stg2_sat_bjaz_hcf_member_dtls__party_identification': ['AGEPROOFTYPE'],
                        'stg2_sat_bjaz_hlt_ensure_mem_dtls__party_identification': ['AGEPROOFTYPE'],
                        'stg2_sat_bjaz_hm_hospital_master__party_identification': ['IDENTIFICATIONNUMBER'],
                        'stg2_sat_bjaz_intermediary__party_identification': ['GSTREGISTRATIONSTATUS', 'GSTIN', 'PANNUMBER'],
                        'stg2_sat_bjaz_intermediary_hist__party_identification': ['GSTREGISTRATIONSTATUS', 'GSTIN', 'PANNUMBER'],
                        'stg2_sat_bjaz_starpkg_ff_dtls__party_identification': ['PASSPORTNUMBER'],
                        'stg2_sat_cp_partners__party_identification': ['IDENTIFICATIONNUMBER', 'VATREGISTRATIONNUMBER']
                    }) }}
