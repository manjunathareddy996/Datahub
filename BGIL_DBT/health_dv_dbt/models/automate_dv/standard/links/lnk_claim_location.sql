{{ config(materialized='incremental') }}

-- STANDARD-MODEL link() for LNK_CLAIM_LOCATION, 7 contributing table(s).
-- Member ends: HUB_CLAIM (CLAIM_HKEY), HUB_LOCATION (LOCATION_HKEY).
-- Rebuilt from the existing, mapper-reviewed production link model (lnk_claim_location.sql) --
-- same source tables and columns, moved to stage()-computed hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_link_bjaz_bandhan_medi_clam__claim_location'
  - 'stg2_link_bjaz_hm_hcm_extract__claim_location'
  - 'stg2_link_bjaz_hm_inward_dtls__claim_location'
  - 'stg2_link_bjaz_hm_orphan_reg__claim_location'
  - 'stg2_link_bjaz_hm_outward_dtls__claim_location'
  - 'stg2_link_bjaz_clm_wg_trans_dtls__claim_location'
  - 'stg2_link_bjaz_clm_wg_trans_dtls_hist__claim_location'
src_pk: 'CLAIM_LOCATION_HKEY'
src_fk:
  - 'CLAIM_HKEY'
  - 'LOCATION_HKEY'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.link(src_pk=metadata_dict['src_pk'],
                     src_fk=metadata_dict['src_fk'],
                     src_ldts=metadata_dict['src_ldts'],
                     src_source=metadata_dict['src_source'],
                     source_model=metadata_dict['source_model']) }}
