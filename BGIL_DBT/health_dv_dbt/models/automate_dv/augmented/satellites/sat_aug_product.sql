{{ config(materialized='incremental') }}

-- AUGMENTED (unconfirmed) sat() for SAT_AUG_PRODUCT (HUB_PRODUCT grain).
-- 3 contributing table(s), union (no attribute merge attempted --
-- these columns were never analysed for cross-table overlap, unlike standard-model
-- satellites). NOT part of the canonical data_v4.js model. Needs mapper review before
-- being treated as equivalent to a standard-model satellite -- see docs.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_aug_bjaz_bandhan_medi_clam__product'
  - 'stg2_aug_bjaz_ctngy_scheme_mst__product'
  - 'stg2_aug_bjaz_hdfc_sec_fhpp__product'
src_pk: 'PRODUCT_HK'
src_payload:
  - 'AUTO_RENEWAL'
  - 'FF_DTLS_ONLY'
  - 'NO_OF_MEMBERS'
  - 'PARAM_NAME'
  - 'PARAM_REF'
  - 'PARENT_FLAG'
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
