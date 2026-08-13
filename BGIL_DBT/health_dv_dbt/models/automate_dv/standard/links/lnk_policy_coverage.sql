{{ config(materialized='incremental') }}

-- STANDARD-MODEL link() for LNK_POLICY_COVERAGE, 6 contributing table(s).
-- Member ends: HUB_COVERAGE (COVERAGE_HKEY), HUB_POLICY (POLICY_HKEY).
-- Rebuilt from the existing, mapper-reviewed production link model (lnk_policy_coverage.sql) --
-- same source tables and columns, moved to stage()-computed hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_link_ba_hcp_dt_mem__policy_coverage'
  - 'stg2_link_ba_hcp_dt_mem_cov__policy_coverage'
  - 'stg2_link_ba_hcp_dt_pol_cov__policy_coverage'
  - 'stg2_link_ba_hcp_dt_premium__policy_coverage'
  - 'stg2_link_bjaz_hg_pol_dtls__policy_coverage'
  - 'stg2_link_t_prem_data_com__policy_coverage'
src_pk: 'POLICY_COVERAGE_HKEY'
src_fk:
  - 'COVERAGE_HKEY'
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
