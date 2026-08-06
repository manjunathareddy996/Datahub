{{ config(materialized='incremental') }}

-- STANDARD-MODEL hub() for HUB_COVERAGE, 8 contributing table(s)
-- across 8 source_model entries (0 via stitch-stage,
-- 8 direct per-table stage()).
-- Rebuilt from the existing, mapper-reviewed production hub model -- same source
-- tables and columns, moved to stage()-computed namespaced hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_hub_ba_hcp_dt_mem__coverage'
  - 'stg2_hub_ba_hcp_dt_mem_cov__coverage'
  - 'stg2_hub_ba_hcp_dt_pol_cov__coverage'
  - 'stg2_hub_ba_hcp_dt_premium__coverage'
  - 'stg2_hub_bjaz_hg_pol_dtls__coverage'
  - 'stg2_hub_bjaz_hm_doctor_multi_assess__coverage'
  - 'stg2_hub_bjaz_hm_doc_recovery__coverage'
  - 'stg2_hub_t_prem_data_com__coverage'
src_pk: 'COVERAGE_HKEY'
src_nk: 'PARENT_BK'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.hub(src_pk=metadata_dict['src_pk'],
                    src_nk=metadata_dict['src_nk'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
