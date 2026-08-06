{{ config(materialized='incremental') }}

-- STANDARD-MODEL link() for LNK_CASE_POLICY, 1 contributing table(s).
-- Member ends: HUB_CASE (CASE_HKEY), HUB_POLICY (POLICY_HKEY).
-- Rebuilt from the existing, mapper-reviewed production link model (lnk_case_policy.sql) --
-- same source tables and columns, moved to stage()-computed hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_link_bjaz_trv_clm_itrack_dtls__case_policy'
src_pk: 'CASE_POLICY_HKEY'
src_fk:
  - 'CASE_HKEY'
  - 'POLICY_HKEY'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.link(src_pk=metadata_dict['src_pk'],
                     src_fk=metadata_dict['src_fk'],
                     src_ldts=metadata_dict['src_ldts'],
                     src_source=metadata_dict['src_source'],
                     source_model=metadata_dict['source_model']) }}
