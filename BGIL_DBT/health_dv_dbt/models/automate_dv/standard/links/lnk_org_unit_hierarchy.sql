{{ config(materialized='incremental') }}

-- STANDARD-MODEL link() for LNK_ORG_UNIT_HIERARCHY, 7 contributing table(s).
-- Member ends: HUB_ORG_UNIT (ORG_UNIT_FROM_HKEY), HUB_ORG_UNIT (ORG_UNIT_TO_HKEY).
-- Rebuilt from the existing, mapper-reviewed production link model (lnk_org_unit_hierarchy.sql) --
-- same source tables and columns, moved to stage()-computed hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_link_bjaz_grp_hlt_dtls__org_unit_hierarchy'
  - 'stg2_link_bjaz_health_webservice_info__org_unit_hierarchy'
  - 'stg2_link_bjaz_hg_pol_dtls__org_unit_hierarchy'
  - 'stg2_link_bjaz_tpa_claim_details_ws__org_unit_hierarchy'
  - 'stg2_link_bjaz_ewr_pol_dtls__org_unit_hierarchy'
  - 'stg2_link_bjaz_pc_online_pol_dtls_mv__org_unit_hierarchy'
  - 'stg2_link_t_prem_data_com__org_unit_hierarchy'
src_pk: 'ORG_UNIT_HIERARCHY_HKEY'
src_fk:
  - 'ORG_UNIT_FROM_HKEY'
  - 'ORG_UNIT_TO_HKEY'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.link(src_pk=metadata_dict['src_pk'],
                     src_fk=metadata_dict['src_fk'],
                     src_ldts=metadata_dict['src_ldts'],
                     src_source=metadata_dict['src_source'],
                     source_model=metadata_dict['source_model']) }}
