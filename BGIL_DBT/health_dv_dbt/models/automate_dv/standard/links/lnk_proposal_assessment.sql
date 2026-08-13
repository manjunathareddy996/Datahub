{{ config(materialized='incremental') }}

-- STANDARD-MODEL link() for LNK_PROPOSAL_ASSESSMENT, 3 contributing table(s).
-- Member ends: HUB_ASSESSMENT (ASSESSMENT_HKEY), HUB_PROPOSAL (PROPOSAL_HKEY).
-- Rebuilt from the existing, mapper-reviewed production link model (lnk_proposal_assessment.sql) --
-- same source tables and columns, moved to stage()-computed hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_link_ba_hcp_pp_mem_dtls__proposal_assessment'
  - 'stg2_link_bjaz_grp_hlt_dtls__proposal_assessment'
  - 'stg2_link_ba_hdfc_lead__proposal_assessment'
src_pk: 'PROPOSAL_ASSESSMENT_HKEY'
src_fk:
  - 'ASSESSMENT_HKEY'
  - 'PROPOSAL_HKEY'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.link(src_pk=metadata_dict['src_pk'],
                     src_fk=metadata_dict['src_fk'],
                     src_ldts=metadata_dict['src_ldts'],
                     src_source=metadata_dict['src_source'],
                     source_model=metadata_dict['source_model']) }}
