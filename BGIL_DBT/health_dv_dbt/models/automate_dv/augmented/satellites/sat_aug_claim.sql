{{ config(materialized='incremental') }}

-- AUGMENTED (unconfirmed) sat() for SAT_AUG_CLAIM (HUB_CLAIM grain).
-- 14 contributing table(s), union (no attribute merge attempted --
-- these columns were never analysed for cross-table overlap, unlike standard-model
-- satellites). NOT part of the canonical data_v4.js model. Needs mapper review before
-- being treated as equivalent to a standard-model satellite -- see docs.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_aug_bjaz_hat_dedution_summary__claim'
  - 'stg2_aug_bjaz_hm_bill_charge__claim'
  - 'stg2_aug_bjaz_hm_bill_detail_ocr__claim'
  - 'stg2_aug_bjaz_hm_coinsu_clm_dtls__claim'
  - 'stg2_aug_bjaz_hm_doctor_assess__claim'
  - 'stg2_aug_bjaz_hm_doctor_multi_assess__claim'
  - 'stg2_aug_bjaz_hm_hcm_extract__claim'
  - 'stg2_aug_bjaz_hm_inward_autoallocation__claim'
  - 'stg2_aug_bjaz_hm_orphan_reg__claim'
  - 'stg2_aug_bjaz_hm_preauth_query__claim'
  - 'stg2_aug_bjaz_remedinet_claim_details__claim'
  - 'stg2_aug_bjaz_tpa_claim_details_ws__claim'
  - 'stg2_aug_bjaz_hat_ocr_bill_details__claim'
  - 'stg2_aug_bjaz_hm_bill_detail__claim'
src_pk: 'CLAIM_HK'
src_payload:
  - 'ADD_STATUS'
  - 'AMT_FRM_PATIENT'
  - 'APPROVED_AMT'
  - 'APPROVED_ON'
  - 'AVAILED_ROOM_RENT_PER_DAY'
  - 'BILLHEAD'
  - 'BILL_AMT'
  - 'BILL_AMT_BREAKUP1'
  - 'BILL_AMT_BREAKUP2'
  - 'BILL_CHARGE_ID'
  - 'CHARGE_ID'
  - 'CLAIMED_AMOUNT'
  - 'CLAIMED_AMT'
  - 'CLAIM_LOD_PHM_PAID'
  - 'DIAGNOSIS_ID'
  - 'DISALLOW_AMT'
  - 'DISALLOW_REASON'
  - 'GRADE'
  - 'I3_PARTICULAR_ID'
  - 'INSURCO_CLAIM_NO'
  - 'LEVEL1'
  - 'LEVEL2'
  - 'LEVEL3'
  - 'LEVEL5'
  - 'OMNI_INWARD_NO'
  - 'ORPHAN_CLAIMNO'
  - 'ORPHAN_CLOSE_YN'
  - 'PACKAGE_FLAG'
  - 'PARTICULAR'
  - 'PCS_YN'
  - 'PRICE'
  - 'QUERY_REPLY'
  - 'REEPORTED_AMT'
  - 'REF_BILL_ID'
  - 'ROOM_RENT_PERC'
  - 'TARIFF_DED_TOTAL'
  - 'TARIFF_EXCESS_DED'
  - 'TOTAL_CLAIMED_AMOUNT'
  - 'TOTAL_DED_SUMMARY'
  - 'TOT_APP_AMTMOU'
  - 'UNIT'
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
