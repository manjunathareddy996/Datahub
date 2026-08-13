{{ config(materialized='incremental') }}

-- STANDARD-MODEL link() for LNK_CLAIM_ASSESSMENT, 5 contributing table(s).
-- Member ends: HUB_ASSESSMENT (ASSESSMENT_HKEY), HUB_CLAIM (CLAIM_HKEY).
-- Rebuilt from the existing, mapper-reviewed production link model (lnk_claim_assessment.sql) --
-- same source tables and columns, moved to stage()-computed hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_link_bjaz_bandhan_medi_clam__claim_assessment'
  - 'stg2_link_bjaz_hm_doctor_assess__claim_assessment'
  - 'stg2_link_bjaz_hm_doctor_multi_assess__claim_assessment'
  - 'stg2_link_bjaz_hm_pcs_multi_assess__claim_assessment'
  - 'stg2_link_bjaz_hm_pro_assessment__claim_assessment'
src_pk: 'CLAIM_ASSESSMENT_HKEY'
src_fk:
  - 'ASSESSMENT_HKEY'
  - 'CLAIM_HKEY'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.link(src_pk=metadata_dict['src_pk'],
                     src_fk=metadata_dict['src_fk'],
                     src_ldts=metadata_dict['src_ldts'],
                     src_source=metadata_dict['src_source'],
                     source_model=metadata_dict['source_model']) }}
