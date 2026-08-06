{{ config(materialized='incremental') }}

-- STANDARD-MODEL hub() for HUB_ASSESSMENT, 25 contributing table(s)
-- across 17 source_model entries (3 via stitch-stage,
-- 14 direct per-table stage()).
-- Rebuilt from the existing, mapper-reviewed production hub model -- same source
-- tables and columns, moved to stage()-computed namespaced hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_hub_ba_hcp_port_wordings__assessment'
  - 'stg2_assessment_medical'
  - 'stg2_hub_ba_hcp_prod_8428_gpg_loader__assessment'
  - 'stg2_assessment_underwriting'
  - 'stg2_hub_ba_hcp_prod_8433_fhc_loader__assessment'
  - 'stg2_hub_bjaz_ehh_pol_dtls__assessment'
  - 'stg2_hub_bjaz_gpg_pol_dtls__assessment'
  - 'stg2_hub_bjaz_grp_hlt_dtls__assessment'
  - 'stg2_hub_bjaz_hcp_transcript_url__assessment'
  - 'stg2_hub_bjaz_health_webservice_info__assessment'
  - 'stg2_hub_bjaz_hm_hat_itrack_dtls__assessment'
  - 'stg2_assessment_header'
  - 'stg2_hub_ba_hdfc_lead__assessment'
  - 'stg2_hub_bjaz_hm_pcs_des_master__assessment'
  - 'stg2_hub_bjaz_hm_pcs_master__assessment'
  - 'stg2_hub_bjaz_scrutiny_ip_dtls__assessment'
  - 'stg2_hub_bjaz_super_suraksha_dtls__assessment'
src_pk: 'ASSESSMENT_HKEY'
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
