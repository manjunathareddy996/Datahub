{{ config(materialized='incremental') }}

-- AUGMENTED (unconfirmed) sat() for SAT_AUG_AGREEMENT (HUB_AGREEMENT grain).
-- 2 contributing table(s), union (no attribute merge attempted --
-- these columns were never analysed for cross-table overlap, unlike standard-model
-- satellites). NOT part of the canonical data_v4.js model. Needs mapper review before
-- being treated as equivalent to a standard-model satellite -- see docs.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_aug_bjaz_hm_hospital_master__agreement'
  - 'stg2_aug_bjaz_hm_hosp_master_extn1__agreement'
src_pk: 'AGREEMENT_HK'
src_payload:
  - 'CBBILLRECTIME'
  - 'CBDISCBUSFIG'
  - 'CBDISCREMARK'
  - 'COSTNEGO'
  - 'DATE_OF_SUP'
  - 'EARLYPAYREMARK'
  - 'ENDDATE1'
  - 'ENDDATE2'
  - 'ENDDATE3'
  - 'ENDDATE4'
  - 'NONCHMSURG'
  - 'PAYMENT_MODE'
  - 'REMARK1'
  - 'REMARK2'
  - 'REMARK3'
  - 'REMARK4'
  - 'STARTDATE1'
  - 'STARTDATE2'
  - 'STARTDATE3'
  - 'STARTDATE4'
  - 'TATRANGE'
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
