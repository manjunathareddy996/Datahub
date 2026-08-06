{{ config(materialized='incremental') }}

-- STANDARD-MODEL ma_sat() for SAT_PARTY_GROUP_CENSUS (HUB_PARTY grain) -- union of 8 table(s), no join needed.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_sat_bgil_gmc_final_instl_data__party_group_census'
  - 'stg2_sat_bjaz_ecard_membr_del_dtls__party_group_census'
  - 'stg2_sat_bjaz_hat_id_mem_detls__party_group_census'
  - 'stg2_sat_bjaz_hc_part_extn__party_group_census'
  - 'stg2_sat_bjaz_hm_coinsu_clm_dtls__party_group_census'
  - 'stg2_sat_bjaz_hm_hcm_extract__party_group_census'
  - 'stg2_sat_bjaz_hm_member_dtls__party_group_census'
  - 'stg2_sat_bjaz_remedinet_claim_details__party_group_census'
src_pk: 'PARTY_HK'
src_cdk:
  - 'MEMBER_REFERENCE_CK'
src_payload:
  - 'ACTIVE_INDICATOR'
  - 'DATE_OF_JOINING'
  - 'DESIGNATION_BAND'
  - 'EMPLOYEE_ID'
  - 'LOCATION_REFERENCE'
  - 'MEMBER_NAME'
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
