{{ config(materialized='incremental') }}

-- TRAVEL AUGMENTED (build-side, no modeler round-trip -- see
-- docs/TRAVEL_FIXES_APPLIED.md) sat() for SAT_AUG_COVERAGE_RATING.
-- PROMOTE-WATCH: coverage-level rating recurs from Health per the mapper -- the
-- model has no canonical coverage-rating satellite at all (both SAT_PRODUCT_RATING_*
-- satellites parent HUB_PRODUCT) -- promote-to-canonical candidate if Motor confirms.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_aug_coverage_rating_bjaz_trv_rider_rate_mast_mv_nb_prm_excluding_st'
  - 'stg2_aug_coverage_rating_bjaz_trv_rider_rate_mast_mv_extn_prm_excluding_st'
  - 'stg2_aug_coverage_rating_bjaz_trv_rider_rate_mast_mv_min_extn_prm'
  - 'stg2_aug_coverage_rating_bjaz_trv_rider_rate_mast_mv_min_nb_prm'
  - 'stg2_aug_coverage_rating_bjaz_trv_rider_dtls_mv_rider_premium'
src_pk: 'COVERAGE_HKEY'
src_payload:
  - 'EXTENSION_PREMIUM_EXCLUDING_ST'
  - 'MINIMUM_EXTENSION_PREMIUM'
  - 'MINIMUM_NEW_BUSINESS_PREMIUM'
  - 'NEW_BUSINESS_PREMIUM_EXCLUDING_ST'
  - 'RIDER_PREMIUM'
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
