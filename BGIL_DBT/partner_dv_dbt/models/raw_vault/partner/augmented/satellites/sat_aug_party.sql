{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key=['PARTY_HKEY', 'HASHDIFF', 'RECORD_SOURCE']
    )
}}

-- PARTNER AUGMENTED (unconfirmed) sat_multi_source() for SAT_AUG_PARTY (HUB_PARTY grain).
-- 13 contributing table(s). NOT part of the canonical
-- data_5a.js model -- needs mapper review before being treated as equivalent to a
-- standard-model satellite.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_aug_azbj_partner_extn__party'
  - 'stg2_aug_bjaz_intermediary__party'
  - 'stg2_aug_bjaz_intermediary_hist__party'
  - 'stg2_aug_bjaz_azbj_part_ext_hist__party'
  - 'stg2_aug_bjaz_ec_mem_dtls_extn__party'
  - 'stg2_aug_bjaz_hcf_member_dtls__party'
  - 'stg2_aug_bjaz_spp_member_dtls__party'
  - 'stg2_aug_bjaz_cp_part_hist__party'
  - 'stg2_aug_bjaz_hc_part_extn__party'
  - 'stg2_aug_cp_partners__party'
  - 'stg2_aug_bjaz_clm_supp_extn__party'
  - 'stg2_aug_bjaz_hm_member_dtls__party'
  - 'stg2_aug_bjaz_hm_hospital_master__party'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'ADHAAR_PAN_LINK_FLAG'
  - 'BMI'
  - 'BMI_FLAG'
  - 'CAUSE_OF_DEATH'
  - 'DATE_OF_BIRTH_M'
  - 'ECS_MANDATE_STATUS'
  - 'EXISTING_CUSTOMER_INDICATOR'
  - 'HEIGHT_FEET'
  - 'HEIGHT_INCHES'
  - 'HNI_FLAG'
  - 'IMPS_ACTIVE_DATE'
  - 'IMPS_END_DATE'
  - 'IT_RETURN_2YR'
  - 'IT_STATUS'
  - 'MARRIAGE_ANNIVERSARY_DATE'
  - 'MONTHLY_SALARY'
  - 'NUMBER_OF_DAUGHTERS'
  - 'NUMBER_OF_SONS'
  - 'OTHER_OCC'
  - 'PAN_AADHAR_LINKED'
  - 'PAN_ACK_DT'
  - 'PAN_APP_NO'
  - 'PAN_STATUS'
  - 'PARENT_ENTITY_REFERENCE'
  - 'PAYMENT_MODE'
  - 'PREGNANT_MONTHS'
  - 'PRIOR_CLAIM_REASON'
  - 'PROOF_OF_DEATH_TYPE'
  - 'SMOKE_CONSUMP'
  - 'TWO_YR_ITR_FLAG'
  - 'WEBSITE_URL'
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
                        'stg2_aug_azbj_partner_extn__party': ['ECS_MANDATE_STATUS', 'EXISTING_CUSTOMER_INDICATOR', 'HNI_FLAG', 'IT_STATUS', 'NUMBER_OF_DAUGHTERS', 'NUMBER_OF_SONS', 'PARENT_ENTITY_REFERENCE', 'WEBSITE_URL'],
                        'stg2_aug_bjaz_intermediary__party': ['IT_RETURN_2YR', 'PAN_AADHAR_LINKED', 'WEBSITE_URL'],
                        'stg2_aug_bjaz_intermediary_hist__party': ['IT_RETURN_2YR', 'PAN_AADHAR_LINKED', 'WEBSITE_URL'],
                        'stg2_aug_bjaz_azbj_part_ext_hist__party': ['ECS_MANDATE_STATUS', 'IT_STATUS', 'PARENT_ENTITY_REFERENCE'],
                        'stg2_aug_bjaz_ec_mem_dtls_extn__party': ['PREGNANT_MONTHS', 'PRIOR_CLAIM_REASON', 'SMOKE_CONSUMP'],
                        'stg2_aug_bjaz_hcf_member_dtls__party': ['BMI_FLAG'],
                        'stg2_aug_bjaz_spp_member_dtls__party': ['BMI', 'HEIGHT_FEET', 'HEIGHT_INCHES', 'OTHER_OCC'],
                        'stg2_aug_bjaz_cp_part_hist__party': ['CAUSE_OF_DEATH', 'PROOF_OF_DEATH_TYPE'],
                        'stg2_aug_bjaz_hc_part_extn__party': ['DATE_OF_BIRTH_M'],
                        'stg2_aug_cp_partners__party': ['CAUSE_OF_DEATH', 'PROOF_OF_DEATH_TYPE'],
                        'stg2_aug_bjaz_clm_supp_extn__party': ['ADHAAR_PAN_LINK_FLAG', 'MARRIAGE_ANNIVERSARY_DATE', 'PAN_ACK_DT', 'PAN_APP_NO', 'PAN_STATUS', 'TWO_YR_ITR_FLAG'],
                        'stg2_aug_bjaz_hm_member_dtls__party': ['MONTHLY_SALARY'],
                        'stg2_aug_bjaz_hm_hospital_master__party': ['IMPS_ACTIVE_DATE', 'IMPS_END_DATE', 'PAYMENT_MODE']
                    }) }}
