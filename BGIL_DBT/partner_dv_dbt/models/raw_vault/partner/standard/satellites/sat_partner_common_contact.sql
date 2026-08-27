{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key=['PARTY_HKEY', 'HASHDIFF', 'RECORD_SOURCE']
    )
}}

-- PARTNER STANDARD-MODEL sat_multi_source() for SAT_COMMON_CONTACT (HUB_PARTY grain) -- 11 source table(s).

{%- set yaml_metadata -%}
source_model:
  - 'stg2_sat_azbj_partner_extn__common_contact'
  - 'stg2_sat_bjaz_azbj_part_ext_hist__common_contact'
  - 'stg2_sat_bjaz_clm_supp_extn__common_contact'
  - 'stg2_sat_bjaz_cp_part_hist__common_contact'
  - 'stg2_sat_bjaz_ctngy_gc_mem_data__common_contact'
  - 'stg2_sat_bjaz_ctngy_pa_mem_dtls__common_contact'
  - 'stg2_sat_bjaz_hm_hospital_master__common_contact'
  - 'stg2_sat_bjaz_hm_member_dtls__common_contact'
  - 'stg2_sat_bjaz_sh_mem_dtls_extn__common_contact'
  - 'stg2_sat_clm_suppliers__common_contact'
  - 'stg2_sat_cp_partners__common_contact'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'ALTERNATEEMAILADDRESS'
  - 'ALTERNATEMOBILENUMBER'
  - 'EMAILADDRESS'
  - 'FAXNUMBER'
  - 'LANDLINENUMBER'
  - 'MOBILENUMBER'
  - 'PREFERREDCONTACTTIME'
  - 'STDCODE'
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
                        'stg2_sat_azbj_partner_extn__common_contact': ['ALTERNATEEMAILADDRESS', 'ALTERNATEMOBILENUMBER', 'LANDLINENUMBER', 'PREFERREDCONTACTTIME'],
                        'stg2_sat_bjaz_azbj_part_ext_hist__common_contact': ['ALTERNATEEMAILADDRESS', 'LANDLINENUMBER', 'PREFERREDCONTACTTIME'],
                        'stg2_sat_bjaz_clm_supp_extn__common_contact': ['EMAILADDRESS', 'LANDLINENUMBER', 'MOBILENUMBER', 'STDCODE'],
                        'stg2_sat_bjaz_cp_part_hist__common_contact': ['EMAILADDRESS', 'FAXNUMBER', 'LANDLINENUMBER'],
                        'stg2_sat_bjaz_ctngy_gc_mem_data__common_contact': ['LANDLINENUMBER'],
                        'stg2_sat_bjaz_ctngy_pa_mem_dtls__common_contact': ['EMAILADDRESS', 'FAXNUMBER', 'LANDLINENUMBER', 'MOBILENUMBER'],
                        'stg2_sat_bjaz_hm_hospital_master__common_contact': ['EMAILADDRESS', 'FAXNUMBER', 'LANDLINENUMBER', 'STDCODE'],
                        'stg2_sat_bjaz_hm_member_dtls__common_contact': ['EMAILADDRESS', 'LANDLINENUMBER'],
                        'stg2_sat_bjaz_sh_mem_dtls_extn__common_contact': ['EMAILADDRESS'],
                        'stg2_sat_clm_suppliers__common_contact': ['LANDLINENUMBER'],
                        'stg2_sat_cp_partners__common_contact': ['EMAILADDRESS', 'FAXNUMBER', 'LANDLINENUMBER']
                    }) }}
