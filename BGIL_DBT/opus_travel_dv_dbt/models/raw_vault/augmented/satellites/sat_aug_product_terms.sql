{{ config(materialized='incremental') }}

-- TRAVEL AUGMENTED (build-side, no modeler round-trip -- see
-- docs/TRAVEL_FIXES_APPLIED.md) sat() for SAT_AUG_PRODUCT_TERMS.


{%- set yaml_metadata -%}
source_model:
  - 'stg2_aug_product_terms_ba_trv_plan_mst_multi_year_yn'
  - 'stg2_aug_product_terms_ba_trv_plan_mst_age_bypass_yn'
  - 'stg2_aug_product_terms_ba_trv_plan_mst_cft_yn'
  - 'stg2_aug_product_terms_bjaz_trv_rate_master_cft_yn'
  - 'stg2_aug_product_terms_bjaz_trv_plan_area'
  - 'stg2_aug_product_terms_bjaz_trv_rate_master_area'
src_pk: 'PRODUCT_HKEY'
src_payload:
  - 'AGE_ELIGIBILITY_BYPASS_INDICATOR'
  - 'CFT_ELIGIBLE_INDICATOR'
  - 'MULTI_YEAR_INDICATOR'
  - 'PLAN_GEOGRAPHICAL_ZONE'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  stg2_aug_product_terms_ba_trv_plan_mst_multi_year_yn: 'OPUS'
  stg2_aug_product_terms_ba_trv_plan_mst_age_bypass_yn: 'OPUS'
  stg2_aug_product_terms_ba_trv_plan_mst_cft_yn: 'OPUS'
  stg2_aug_product_terms_bjaz_trv_rate_master_cft_yn: 'OPUS'
  stg2_aug_product_terms_bjaz_trv_plan_area: 'OPUS'
  stg2_aug_product_terms_bjaz_trv_rate_master_area: 'OPUS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ sat_multi_source(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model'],
                    src_record_source_map=metadata_dict['src_record_source_map']) }}
