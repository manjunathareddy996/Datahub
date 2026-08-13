{{ config(materialized='incremental') }}

-- STANDARD-MODEL link() for LNK_ASSESSMENT_PARTY, 10 contributing table(s).
-- Member ends: HUB_ASSESSMENT (ASSESSMENT_HKEY), HUB_PARTY (PARTY_HKEY).
-- Rebuilt from the existing, mapper-reviewed production link model (lnk_assessment_party.sql) --
-- same source tables and columns, moved to stage()-computed hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_link_ba_hcp_pp_mem_dtls__assessment_party'
  - 'stg2_link_ba_hcp_prod_8428_gpg_loader__assessment_party'
  - 'stg2_link_ba_hcp_prod_8432_ecp_loader__assessment_party'
  - 'stg2_link_ba_hcp_prod_8433_fhc_loader__assessment_party'
  - 'stg2_link_ba_hcp_prod_8439_clh_loader__assessment_party'
  - 'stg2_link_bjaz_bandhan_medi_clam__assessment_party'
  - 'stg2_link_bjaz_gpg_pol_dtls__assessment_party'
  - 'stg2_link_bjaz_scr_hlth_portable_dtls__assessment_party'
  - 'stg2_link_ba_hdfc_lead__assessment_party'
  - 'stg2_link_bjaz_super_suraksha_dtls__assessment_party'
src_pk: 'ASSESSMENT_PARTY_HKEY'
src_fk:
  - 'ASSESSMENT_HKEY'
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
