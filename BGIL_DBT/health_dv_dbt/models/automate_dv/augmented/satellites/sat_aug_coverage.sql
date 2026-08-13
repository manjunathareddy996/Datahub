{{ config(materialized='incremental') }}

-- AUGMENTED (unconfirmed) sat() for SAT_AUG_COVERAGE (HUB_COVERAGE grain).
-- 3 contributing table(s), union (no attribute merge attempted --
-- these columns were never analysed for cross-table overlap, unlike standard-model
-- satellites). NOT part of the canonical data_v4.js model. Needs mapper review before
-- being treated as equivalent to a standard-model satellite -- see docs.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_aug_ba_hcp_dt_mem_cov__coverage'
  - 'stg2_aug_ba_hcp_dt_premium__coverage'
  - 'stg2_aug_bjaz_hg_pol_dtls__coverage'
src_pk: 'COVERAGE_HK'
src_payload:
  - 'PAN_IND_COVER_YN'
  - 'PREM_BASE_COVER'
  - 'SELF_COVERED_FLAG'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
