{{ config(materialized='incremental') }}

-- STANDARD-MODEL hub() for HUB_PAYMENT_INSTRUMENT, 4 contributing table(s)
-- across 3 source_model entries (0 via stitch-stage,
-- 3 direct per-table stage()).
-- Rebuilt from the existing, mapper-reviewed production hub model -- same source
-- tables and columns, moved to stage()-computed namespaced hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_hub_bjaz_hm_hcm_extract__payment_instrument'
  - 'stg2_hub_bjaz_hm_investi_payment__payment_instrument'
  - 'stg2_hub_bjaz_tpa_claim_details_ws__payment_instrument'
src_pk: 'PAYMENT_INSTRUMENT_HKEY'
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
