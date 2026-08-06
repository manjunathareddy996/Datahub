{{ config(materialized='incremental') }}

-- STANDARD-MODEL link() for LNK_QUOTE_PROPOSAL, 2 contributing table(s).
-- Member ends: HUB_PROPOSAL (PROPOSAL_HKEY), HUB_QUOTE (QUOTE_HKEY).
-- Rebuilt from the existing, mapper-reviewed production link model (lnk_quote_proposal.sql) --
-- same source tables and columns, moved to stage()-computed hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_link_bjaz_grp_hlt_dtls__quote_proposal'
  - 'stg2_link_bjaz_hg_pol_dtls__quote_proposal'
src_pk: 'QUOTE_PROPOSAL_HKEY'
src_fk:
  - 'PROPOSAL_HKEY'
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
