{{ config(materialized='incremental') }}

-- STANDARD-MODEL link() for LNK_CASE_PARTY, 3 contributing table(s).
-- Member ends: HUB_CASE (CASE_HKEY), HUB_PARTY (PARTY_HKEY).
-- Rebuilt from the existing, mapper-reviewed production link model (lnk_case_party.sql) --
-- same source tables and columns, moved to stage()-computed hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_link_bjaz_hm_preauth_enhance__case_party'
  - 'stg2_link_bjaz_hm_preauth_query__case_party'
  - 'stg2_link_bjaz_scr_hlth_portable_dtls__case_party'
src_pk: 'CASE_PARTY_HKEY'
src_fk:
  - 'CASE_HKEY'
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
