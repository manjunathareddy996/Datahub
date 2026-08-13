{{ config(materialized='incremental') }}

-- STANDARD-MODEL link() for LNK_AGREEMENT_PARTY, 4 contributing table(s).
-- Member ends: HUB_AGREEMENT (AGREEMENT_HKEY), HUB_PARTY (PARTY_HKEY).
-- Rebuilt from the existing, mapper-reviewed production link model (lnk_agreement_party.sql) --
-- same source tables and columns, moved to stage()-computed hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_link_bjaz_hm_hospital_master__agreement_party'
  - 'stg2_link_bjaz_hm_hospital_master_extn__agreement_party'
  - 'stg2_link_bjaz_hm_hosp_master_extn1__agreement_party'
  - 'stg2_link_bjaz_remedinet_claim_details__agreement_party'
src_pk: 'AGREEMENT_PARTY_HKEY'
src_fk:
  - 'AGREEMENT_HKEY'
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
