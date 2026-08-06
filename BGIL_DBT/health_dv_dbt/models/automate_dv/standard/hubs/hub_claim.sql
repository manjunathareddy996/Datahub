{{ config(materialized='incremental') }}

-- STANDARD-MODEL hub() for HUB_CLAIM, 61 contributing table(s)
-- across 18 source_model entries (7 via stitch-stage,
-- 11 direct per-table stage()).
-- Rebuilt from the existing, mapper-reviewed production hub model -- same source
-- tables and columns, moved to stage()-computed namespaced hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_hub_bjaz_bandhan_medi_clam__claim'
  - 'stg2_hub_bjaz_hat_case_ocr_dtls__claim'
  - 'stg2_claim_bill_digitisation'
  - 'stg2_claim_header'
  - 'stg2_claim_provider_billing'
  - 'stg2_hub_bjaz_hm_bill_payment__claim'
  - 'stg2_claim_tpa_interaction'
  - 'stg2_claim_health_detail'
  - 'stg2_claim_settlement'
  - 'stg2_hub_bjaz_hm_doc_recovery__claim'
  - 'stg2_hub_bjaz_hm_exclusion_apply__claim'
  - 'stg2_hub_bjaz_hm_investi_payment__claim'
  - 'stg2_hub_bjaz_hm_inward_dtls__claim'
  - 'stg2_hub_bjaz_hm_outward_dtls__claim'
  - 'stg2_hub_bjaz_hm_pcs_multi_assess__claim'
  - 'stg2_hub_bjaz_hm_preauth_query__claim'
  - 'stg2_claim_repudiation'
  - 'stg2_hub_bjaz_hm_query_remark__claim'
src_pk: 'CLAIM_HKEY'
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
