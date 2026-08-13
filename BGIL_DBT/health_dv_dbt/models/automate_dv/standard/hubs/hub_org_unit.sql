{{ config(materialized='incremental') }}

-- STANDARD-MODEL hub() for HUB_ORG_UNIT, 21 contributing table(s)
-- across 13 source_model entries (0 via stitch-stage,
-- 13 direct per-table stage()).
-- Rebuilt from the existing, mapper-reviewed production hub model -- same source
-- tables and columns, moved to stage()-computed namespaced hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_hub_ba_hcp_prod_8428_gpg_loader__org_unit'
  - 'stg2_hub_ba_hcp_prod_8432_ecp_loader__org_unit'
  - 'stg2_hub_ba_hcp_prod_8433_fhc_loader__org_unit'
  - 'stg2_hub_ba_hcp_prod_8439_clh_loader__org_unit'
  - 'stg2_hub_bjaz_ehh_pol_dtls__org_unit'
  - 'stg2_hub_bjaz_gpg_pol_dtls__org_unit'
  - 'stg2_hub_bjaz_grp_hlt_dtls__org_unit'
  - 'stg2_hub_bjaz_health_webservice_info__org_unit'
  - 'stg2_hub_bjaz_hg_pol_dtls__org_unit'
  - 'stg2_hub_bjaz_tpa_claim_details_ws__org_unit'
  - 'stg2_hub_bjaz_ewr_pol_dtls__org_unit'
  - 'stg2_hub_bjaz_pc_online_pol_dtls_mv__org_unit'
  - 'stg2_hub_t_prem_data_com__org_unit'
src_pk: 'ORG_UNIT_HKEY'
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
