{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key=['PARTY_HKEY', 'HASHDIFF', 'RECORD_SOURCE']
    )
}}

-- PARTNER STANDARD-MODEL sat_multi_source() for SAT_PARTY_GROUP_CENSUS (HUB_PARTY grain) -- 11 source table(s).

{%- set yaml_metadata -%}
source_model:
  - 'stg2_sat_azbj_partner_extn__party_group_census'
  - 'stg2_sat_bjaz_azbj_part_ext_hist__party_group_census'
  - 'stg2_sat_bjaz_clm_supp_extn__party_group_census'
  - 'stg2_sat_bjaz_ctngy_pa_mem_dtls__party_group_census'
  - 'stg2_sat_bjaz_ec_mem_dtls_extn__party_group_census'
  - 'stg2_sat_bjaz_hcf_member_dtls__party_group_census'
  - 'stg2_sat_bjaz_hlt_ensure_mem_dtls__party_group_census'
  - 'stg2_sat_bjaz_hm_member_dtls__party_group_census'
  - 'stg2_sat_bjaz_pa_detl_extn__party_group_census'
  - 'stg2_sat_bjaz_sh_mem_dtls_extn__party_group_census'
  - 'stg2_sat_bjaz_spp_member_dtls__party_group_census'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'ACTIVEINDICATOR'
  - 'DESIGNATIONBAND'
  - 'EMPLOYEEID'
  - 'LOCATIONREFERENCE'
  - 'MEMBERREFERENCE'
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
