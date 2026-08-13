{{ config(materialized='incremental') }}

-- STANDARD-MODEL hub() for HUB_PARTY, 115 contributing table(s)
-- across 17 source_model entries (4 via stitch-stage,
-- 13 direct per-table stage()).
-- Rebuilt from the existing, mapper-reviewed production hub model -- same source
-- tables and columns, moved to stage()-computed namespaced hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_party_identity'
  - 'stg2_party_group_household'
  - 'stg2_hub_bjaz_ecard_membr_del_dtls__party'
  - 'stg2_hub_bjaz_grp_hlt_imd_dtls__party'
  - 'stg2_hub_bjaz_grp_tpa_extn__party'
  - 'stg2_hub_bjaz_hat_case_ocr_dtls__party'
  - 'stg2_hub_bjaz_hm_bill_payment__party'
  - 'stg2_hub_bjaz_hm_clm_register__party'
  - 'stg2_hub_bjaz_hm_investi_payment__party'
  - 'stg2_hub_bjaz_hm_policy_usermapping__party'
  - 'stg2_hub_bjaz_hm_preauth_enhance__party'
  - 'stg2_hub_bjaz_hm_preauth_query__party'
  - 'stg2_party_health_profile'
  - 'stg2_hub_ba_hdfc_lead__party'
  - 'stg2_hub_bjaz_clm_pre_auth_hlt_dtls__party'
  - 'stg2_hub_bjaz_hdfc_surk_shop__party'
  - 'stg2_lnk_role_employee'
src_pk: 'PARTY_HKEY'
src_nk: 'PARENT_BK'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.hub(src_pk=metadata_dict['src_pk'],
                    src_nk=metadata_dict['src_nk'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
