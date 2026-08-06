{{ config(materialized='incremental') }}

-- AUGMENTED (unconfirmed) sat() for SAT_AUG_DISTRIBUTION_CHANNEL (HUB_DISTRIBUTION_CHANNEL grain).
-- 1 contributing table(s), union (no attribute merge attempted --
-- these columns were never analysed for cross-table overlap, unlike standard-model
-- satellites). NOT part of the canonical data_v4.js model. Needs mapper review before
-- being treated as equivalent to a standard-model satellite -- see docs.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_aug_bjaz_hdfc_sec_fhpp__distribution_channel'
src_pk: 'DISTRIBUTION_CHANNEL_HK'
src_payload:
  - 'BDR_CODE'
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
