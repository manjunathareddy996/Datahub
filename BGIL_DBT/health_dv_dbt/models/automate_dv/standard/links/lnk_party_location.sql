{{ config(materialized='incremental') }}

-- STANDARD-MODEL link() for LNK_PARTY_LOCATION, 12 contributing table(s) -- extended per
-- data_5a.js / MAPPER_NOTE_V5_MODELSYNC.md M4: 4 more source_model entries added (the
-- former SAT_PARTY_ADDRESS_USAGE tables), reusing the SAME PARTY_HK/LOCATION_HK namespaced-
-- hash formula as the original 8, so these hkeys are guaranteed identical to what
-- hub_party.sql / proto/standard HUB_LOCATION already compute for the same raw values --
-- genuine foreign keys, not independently re-derived. LOCATION_HK for these 4 is the
-- synthetic composite-address key (no real location code on these tables) -- see
-- stg2_addrusage_*.sql for the derivation and its known fragility (two spellings of the
-- same address won't dedupe).
-- Rebuilt from the existing, mapper-reviewed production link model (lnk_party_location.sql) --
-- same source tables and columns, moved to stage()-computed hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_link_ba_hcp_pol_mst__party_location'
  - 'stg2_link_bjaz_bandhan_medi_clam__party_location'
  - 'stg2_link_bjaz_hm_hcm_extract__party_location'
  - 'stg2_link_bjaz_hm_hospital_master__party_location'
  - 'stg2_link_bjaz_hm_inward_dtls__party_location'
  - 'stg2_link_bjaz_gc_group_guard_dtls__party_location'
  - 'stg2_link_bjaz_pnb_gpa_data__party_location'
  - 'stg2_link_bjaz_super_suraksha_dtls__party_location'
  - 'stg2_addrusage_ba_hcp_pp_mem_dtls'
  - 'stg2_addrusage_bjaz_bandhan_medi_clam'
  - 'stg2_addrusage_bjaz_tpa_claim_details_ws'
  - 'stg2_addrusage_bjaz_hat_id_mem_detls'
src_pk: 'PARTY_LOCATION_HKEY'
src_fk:
  - 'LOCATION_HKEY'
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
