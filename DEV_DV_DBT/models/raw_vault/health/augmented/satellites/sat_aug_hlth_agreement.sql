{{ config(materialized='incremental') }}

-- AUGMENTED sat_multi_source() for SAT_AUG_AGREEMENT (HUB_AGREEMENT grain).
-- 2 contributing table(s) with non-identical payload columns.
-- Uses sat_multi_source macro to handle NULL-filling across sources.

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
src_column_map:
  stg2_aug_bjaz_hm_hospital_master__agreement:
    - 'DATE_OF_SUP'
    - 'PAYMENT_MODE'
  stg2_aug_bjaz_hm_hosp_master_extn1__agreement:
    - 'CBBILLRECTIME'
    - 'CBDISCBUSFIG'
    - 'CBDISCREMARK'
    - 'COSTNEGO'
    - 'EARLYPAYREMARK'
    - 'ENDDATE1'
    - 'ENDDATE2'
    - 'ENDDATE3'
    - 'ENDDATE4'
    - 'NONCHMSURG'
    - 'REMARK1'
    - 'REMARK2'
    - 'REMARK3'
    - 'REMARK4'
    - 'STARTDATE1'
    - 'STARTDATE2'
    - 'STARTDATE3'
    - 'STARTDATE4'
    - 'TATRANGE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ sat_multi_source(src_pk=metadata_dict['src_pk'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_payload=metadata_dict['src_payload'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model'],
                    src_column_map=metadata_dict['src_column_map']) }}
