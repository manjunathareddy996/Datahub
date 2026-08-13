{{ config(materialized='incremental') }}

-- STANDARD-MODEL link() for LNK_PARTY_ROLE, 2 contributing table(s).
-- Member ends: HUB_PARTY (PARTY_HKEY), LNK_PARTY_ROLE (LINK_INSTANCE_HKEY).
-- Rebuilt from the existing, mapper-reviewed production link model (lnk_party_role.sql) --
-- same source tables and columns, moved to stage()-computed hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_link_ba_hcp_dt_mem_cov__party_role'
  - 'stg2_link_ba_hcp_pp_mem_dtls__party_role'
src_pk: 'PARTY_ROLE_HKEY'
src_fk:
  - 'PARTY_HKEY'
  - 'LINK_INSTANCE_HKEY'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.link(src_pk=metadata_dict['src_pk'],
                     src_fk=metadata_dict['src_fk'],
                     src_ldts=metadata_dict['src_ldts'],
                     src_source=metadata_dict['src_source'],
                     source_model=metadata_dict['source_model']) }}
