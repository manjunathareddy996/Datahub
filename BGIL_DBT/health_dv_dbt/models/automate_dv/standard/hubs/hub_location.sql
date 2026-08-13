{{ config(materialized='incremental') }}

-- STANDARD-MODEL hub() for HUB_LOCATION, 18 contributing table(s)
-- across 12 source_model entries (1 via stitch-stage,
-- 11 direct per-table stage()).
-- Rebuilt from the existing, mapper-reviewed production hub model -- same source
-- tables and columns, moved to stage()-computed namespaced hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_hub_ba_hcp_pol_mst__location'
  - 'stg2_hub_bjaz_bandhan_medi_clam__location'
  - 'stg2_common_address'
  - 'stg2_hub_bjaz_hm_claim_status_dash_app__location'
  - 'stg2_hub_bjaz_hm_outward_dtls__location'
  - 'stg2_hub_bjaz_clm_supp_extn__location'
  - 'stg2_hub_bjaz_clm_wg_trans_dtls__location'
  - 'stg2_hub_bjaz_clm_wg_trans_dtls_hist__location'
  - 'stg2_hub_bjaz_gc_group_guard_dtls__location'
  - 'stg2_hub_bjaz_pnb_gpa_data__location'
  - 'stg2_hub_bjaz_super_suraksha_dtls__location'
  - 'stg2_hub_ng_hcm_inward_details__location'
src_pk: 'LOCATION_HKEY'
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
