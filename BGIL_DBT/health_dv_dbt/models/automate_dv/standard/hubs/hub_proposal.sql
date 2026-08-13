{{ config(materialized='incremental') }}

-- STANDARD-MODEL hub() for HUB_PROPOSAL, 19 contributing table(s)
-- across 12 source_model entries (0 via stitch-stage,
-- 12 direct per-table stage()).
-- Rebuilt from the existing, mapper-reviewed production hub model -- same source
-- tables and columns, moved to stage()-computed namespaced hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_hub_ba_hcp_pp_mem_dtls__proposal'
  - 'stg2_hub_bjaz_gp_hospital_cash__proposal'
  - 'stg2_hub_bjaz_grp_hlt_dtls__proposal'
  - 'stg2_hub_bjaz_hdfc_sec_fhpp__proposal'
  - 'stg2_hub_bjaz_hg_pol_dtls__proposal'
  - 'stg2_hub_ba_hdfc_lead__proposal'
  - 'stg2_hub_bjaz_adld_prem_dtls__proposal'
  - 'stg2_hub_bjaz_flexi_cyber_data__proposal'
  - 'stg2_hub_bjaz_gg_prem_dtls__proposal'
  - 'stg2_hub_bjaz_hdfc_flexipa__proposal'
  - 'stg2_hub_bjaz_pnb_gpa_data__proposal'
  - 'stg2_hub_bjaz_rr_prem_dtls__proposal'
src_pk: 'PROPOSAL_HKEY'
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
