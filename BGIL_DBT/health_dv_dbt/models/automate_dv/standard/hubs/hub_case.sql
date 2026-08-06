{{ config(materialized='incremental') }}

-- STANDARD-MODEL hub() for HUB_CASE, 6 contributing table(s)
-- across 6 source_model entries (0 via stitch-stage,
-- 6 direct per-table stage()).
-- Rebuilt from the existing, mapper-reviewed production hub model -- same source
-- tables and columns, moved to stage()-computed namespaced hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_hub_bjaz_hm_hat_itrack_dtls__case'
  - 'stg2_hub_bjaz_hm_inward_autoallocation__case'
  - 'stg2_hub_bjaz_hm_preauth_enhance__case'
  - 'stg2_hub_bjaz_hm_preauth_query__case'
  - 'stg2_hub_bjaz_scr_hlth_portable_dtls__case'
  - 'stg2_hub_bjaz_trv_clm_itrack_dtls__case'
src_pk: 'CASE_HKEY'
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
