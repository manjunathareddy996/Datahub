{{ config(materialized='incremental') }}

-- PARTNER STANDARD-MODEL link() for LNK_POLICY_PARTY, 14 contributing table(s).

{%- set yaml_metadata -%}
source_model:
  - 'stg2_link_azbj_partner_extn__policy_party'
  - 'stg2_link_ba_hcp_dt_mem__policy_party'
  - 'stg2_link_bjaz_ctngy_ff_dtls_extn__policy_party'
  - 'stg2_link_bjaz_ctngy_pa_mem_dtls__policy_party'
  - 'stg2_link_bjaz_ec_mem_dtls_extn__policy_party'
  - 'stg2_link_bjaz_hcf_member_dtls__policy_party'
  - 'stg2_link_bjaz_hc_part_extn__policy_party'
  - 'stg2_link_bjaz_hlt_ensure_mem_dtls__policy_party'
  - 'stg2_link_bjaz_hm_member_dtls__policy_party'
  - 'stg2_link_bjaz_pa_detl_extn__policy_party'
  - 'stg2_link_bjaz_sh_mem_dtls_extn__policy_party'
  - 'stg2_link_bjaz_spp_member_dtls__policy_party'
  - 'stg2_link_bjaz_starpkg_ff_dtls__policy_party'
  - 'stg2_link_ocp_interested_parties__policy_party'
src_pk: 'POLICY_PARTY_HKEY'
src_fk:
  - 'PARTY_HKEY'
  - 'POLICY_HKEY'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.link(src_pk=metadata_dict['src_pk'],
                     src_fk=metadata_dict['src_fk'],
                     src_ldts=metadata_dict['src_ldts'],
                     src_source=metadata_dict['src_source'],
                     source_model=metadata_dict['source_model']) }}
