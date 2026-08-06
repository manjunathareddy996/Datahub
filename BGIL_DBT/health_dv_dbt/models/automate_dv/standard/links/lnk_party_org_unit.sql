{{ config(materialized='incremental') }}

-- STANDARD-MODEL link() for LNK_PARTY_ORG_UNIT, 9 contributing table(s).
-- Member ends: HUB_ORG_UNIT (ORG_UNIT_HKEY), HUB_PARTY (PARTY_HKEY).
-- Rebuilt from the existing, mapper-reviewed production link model (lnk_party_org_unit.sql) --
-- same source tables and columns, moved to stage()-computed hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_link_ba_hcp_prod_8428_gpg_loader__party_org_unit'
  - 'stg2_link_ba_hcp_prod_8432_ecp_loader__party_org_unit'
  - 'stg2_link_ba_hcp_prod_8433_fhc_loader__party_org_unit'
  - 'stg2_link_ba_hcp_prod_8439_clh_loader__party_org_unit'
  - 'stg2_link_bjaz_gpg_pol_dtls__party_org_unit'
  - 'stg2_link_bjaz_hg_pol_dtls__party_org_unit'
  - 'stg2_link_bjaz_tpa_claim_details_ws__party_org_unit'
  - 'stg2_link_bjaz_ewr_pol_dtls__party_org_unit'
  - 'stg2_link_bjaz_pc_online_pol_dtls_mv__party_org_unit'
src_pk: 'PARTY_ORG_UNIT_HKEY'
src_fk:
  - 'ORG_UNIT_HKEY'
  - 'PARTY_HKEY'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.link(src_pk=metadata_dict['src_pk'],
                     src_fk=metadata_dict['src_fk'],
                     src_ldts=metadata_dict['src_ldts'],
                     src_source=metadata_dict['src_source'],
                     source_model=metadata_dict['source_model']) }}
