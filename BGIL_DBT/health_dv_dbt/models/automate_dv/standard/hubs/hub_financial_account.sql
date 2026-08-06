{{ config(materialized='incremental') }}

-- STANDARD-MODEL hub() for HUB_FINANCIAL_ACCOUNT, 18 contributing table(s)
-- across 15 source_model entries (1 via stitch-stage,
-- 14 direct per-table stage()).
-- Rebuilt from the existing, mapper-reviewed production hub model -- same source
-- tables and columns, moved to stage()-computed namespaced hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_account_definition'
  - 'stg2_hub_ba_hcp_prod_8432_ecp_loader__financial_account'
  - 'stg2_hub_ba_hcp_prod_8433_fhc_loader__financial_account'
  - 'stg2_hub_bjaz_gpg_pol_dtls__financial_account'
  - 'stg2_hub_bjaz_gp_hospital_cash__financial_account'
  - 'stg2_hub_bjaz_hdfc_sec_fhpp__financial_account'
  - 'stg2_hub_bjaz_health_webservice_info__financial_account'
  - 'stg2_hub_bjaz_hm_hcm_extract__financial_account'
  - 'stg2_hub_bjaz_hm_member_dtls__financial_account'
  - 'stg2_hub_bjaz_adld_prem_dtls__financial_account'
  - 'stg2_hub_bjaz_flexi_cyber_data__financial_account'
  - 'stg2_hub_bjaz_gg_prem_dtls__financial_account'
  - 'stg2_hub_bjaz_hdfc_flexipa__financial_account'
  - 'stg2_hub_bjaz_pnb_gpa_data__financial_account'
  - 'stg2_hub_bjaz_rr_prem_dtls__financial_account'
src_pk: 'FINANCIAL_ACCOUNT_HKEY'
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
