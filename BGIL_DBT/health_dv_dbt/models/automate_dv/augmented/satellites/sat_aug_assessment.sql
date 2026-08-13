{{ config(materialized='incremental') }}

-- AUGMENTED (unconfirmed) sat() for SAT_AUG_ASSESSMENT (HUB_ASSESSMENT grain).
-- 5 contributing table(s), union (no attribute merge attempted --
-- these columns were never analysed for cross-table overlap, unlike standard-model
-- satellites). NOT part of the canonical data_v4.js model. Needs mapper review before
-- being treated as equivalent to a standard-model satellite -- see docs.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_aug_ba_hcp_pp_mem_dtls__assessment'
  - 'stg2_aug_bjaz_hcp_transcript_url__assessment'
  - 'stg2_aug_bjaz_hm_doctor_assess__assessment'
  - 'stg2_aug_bjaz_hm_doctor_multi_assess__assessment'
  - 'stg2_aug_bjaz_hm_pro_assessment__assessment'
src_pk: 'ASSESSMENT_HK'
src_payload:
  - 'APP_TIME'
  - 'DIAGNOSIS_DETAIL'
  - 'FINAL_DIAGNOSIS'
  - 'HLTH_TIPS'
  - 'ICD_ID'
  - 'PAY_TYPE'
  - 'PCS_YN'
  - 'RESCHEDULE_DATE'
  - 'RESCHEDULE_TIME'
  - 'SUB_STATUS_CODE'
  - 'V_SECOND_SCR'
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
