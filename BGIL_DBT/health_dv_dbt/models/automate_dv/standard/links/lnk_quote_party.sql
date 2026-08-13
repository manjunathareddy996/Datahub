{{ config(materialized='incremental') }}

-- STANDARD-MODEL link() for LNK_QUOTE_PARTY, 5 contributing table(s).
-- Member ends: HUB_PARTY (PARTY_HKEY), HUB_QUOTE (QUOTE_HKEY).
-- Rebuilt from the existing, mapper-reviewed production link model (lnk_quote_party.sql) --
-- same source tables and columns, moved to stage()-computed hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_link_bjaz_ecard_membr_del_dtls__quote_party'
  - 'stg2_link_bjaz_grp_hlt_imd_dtls__quote_party'
  - 'stg2_link_bjaz_hg_pol_dtls__quote_party'
  - 'stg2_link_bjaz_ewr_pol_dtls__quote_party'
  - 'stg2_link_bjaz_hdfc_surk_shop__quote_party'
src_pk: 'QUOTE_PARTY_HKEY'
src_fk:
  - 'PARTY_HKEY'
  - 'QUOTE_HKEY'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.link(src_pk=metadata_dict['src_pk'],
                     src_fk=metadata_dict['src_fk'],
                     src_ldts=metadata_dict['src_ldts'],
                     src_source=metadata_dict['src_source'],
                     source_model=metadata_dict['source_model']) }}
