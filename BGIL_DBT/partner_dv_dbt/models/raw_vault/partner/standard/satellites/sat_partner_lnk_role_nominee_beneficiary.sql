{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key=['PARTY_HKEY', 'HASHDIFF', 'RECORD_SOURCE']
    )
}}

-- PARTNER STANDARD-MODEL sat_multi_source() for SAT_LNK_ROLE_NOMINEE_BENEFICIARY (HUB_PARTY grain, role-special: 'nominee_beneficiary').

{%- set yaml_metadata -%}
source_model:
  - 'stg2_rolesat_bjaz_ctngy_ff_dtls_extn__lnk_role_nominee_beneficiary'
  - 'stg2_rolesat_bjaz_ctngy_gc_mem_data__lnk_role_nominee_beneficiary'
  - 'stg2_rolesat_bjaz_ctngy_pa_mem_dtls__lnk_role_nominee_beneficiary'
  - 'stg2_rolesat_bjaz_ec_mem_dtls_extn__lnk_role_nominee_beneficiary'
  - 'stg2_rolesat_bjaz_hcf_member_dtls__lnk_role_nominee_beneficiary'
  - 'stg2_rolesat_bjaz_hc_part_extn__lnk_role_nominee_beneficiary'
  - 'stg2_rolesat_bjaz_hlt_ensure_mem_dtls__lnk_role_nominee_beneficiary'
  - 'stg2_rolesat_bjaz_hm_member_dtls__lnk_role_nominee_beneficiary'
  - 'stg2_rolesat_bjaz_pa_detl_extn__lnk_role_nominee_beneficiary'
  - 'stg2_rolesat_bjaz_sh_mem_dtls_extn__lnk_role_nominee_beneficiary'
  - 'stg2_rolesat_bjaz_spp_member_dtls__lnk_role_nominee_beneficiary'
  - 'stg2_rolesat_bjaz_starpkg_ff_dtls__lnk_role_nominee_beneficiary'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'APPOINTEE_NAME'
  - 'RELATIONSHIP_TO_INSURED'
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
