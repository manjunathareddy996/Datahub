{{ config(materialized='incremental') }}

-- STANDARD-MODEL link() for LNK_POLICY_LOCATION, 13 contributing table(s).
-- Member ends: HUB_LOCATION (LOCATION_HKEY), HUB_POLICY (POLICY_HKEY).
-- Rebuilt from the existing, mapper-reviewed production link model (lnk_policy_location.sql) --
-- same source tables and columns, moved to stage()-computed hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_link_ba_hcp_pol_mst__policy_location'
  - 'stg2_link_bjaz_bandhan_medi_clam__policy_location'
  - 'stg2_link_bjaz_ehh_pol_dtls__policy_location'
  - 'stg2_link_bjaz_generic_loader_log_table__policy_location'
  - 'stg2_link_bjaz_hm_hcm_extract__policy_location'
  - 'stg2_link_bjaz_hm_inward_dtls__policy_location'
  - 'stg2_link_bjaz_hm_orphan_reg__policy_location'
  - 'stg2_link_bjaz_hm_outward_dtls__policy_location'
  - 'stg2_link_bjaz_clm_wg_trans_dtls__policy_location'
  - 'stg2_link_bjaz_clm_wg_trans_dtls_hist__policy_location'
  - 'stg2_link_bjaz_gc_group_guard_dtls__policy_location'
  - 'stg2_link_bjaz_pnb_gpa_data__policy_location'
  - 'stg2_link_bjaz_super_suraksha_dtls__policy_location'
src_pk: 'POLICY_LOCATION_HKEY'
src_fk:
  - 'LOCATION_HKEY'
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
