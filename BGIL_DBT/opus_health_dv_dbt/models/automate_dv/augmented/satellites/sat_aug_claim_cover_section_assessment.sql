-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_AUG_CLAIM_COVER_SECTION_ASSESSMENT (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_v05_claim.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_claim_cover_section_assessment'
src_pk: 'CLAIM_HKEY'
src_cdk:
  - 'COVER_SECTION_CODE_CK'
src_payload:
  - 'ADVENTURE_SPORTS_INVOLVEMENT'
  - 'ADVERSE_MEDICAL_HISTORY_FINDING'
  - 'ASSESSMENT_COMPLETED_DATE'
  - 'ASSESSMENT_PARAMETER_SLOT_10_VALUE'
  - 'ASSESSMENT_PARAMETER_SLOT_11_VALUE'
  - 'ASSESSMENT_PARAMETER_SLOT_12_VALUE'
  - 'ASSESSMENT_PARAMETER_SLOT_1_VALUE'
  - 'ASSESSOR_COMMENT'
  - 'ASSESSOR_GENERAL_REMARKS'
  - 'CASE_MANAGEMENT_INDICATOR'
  - 'EDUCATION_BENEFIT_CHILD_COUNT'
  - 'EMI_BENEFIT_DAY_COUNT'
  - 'EMI_BENEFIT_FITNESS_DATE'
  - 'EMI_BENEFIT_INJURY_DATE'
  - 'EMI_INSTALMENT_AMOUNT'
  - 'EMI_INSTALMENT_COUNT'
  - 'FUNERAL_DATE'
  - 'FURTHER_INFORMATION_REQUIRED'
  - 'HOSPITALISATION_DAYS_DISALLOWED'
  - 'HOSPITALISATION_PARTICULARS'
  - 'LAST_EMI_PAID_DATE'
  - 'NON_DISCLOSURE_FINDING'
  - 'OUTSTANDING_LOAN_AMOUNT'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.ma_sat(src_pk=metadata_dict['src_pk'],
                      src_cdk=metadata_dict['src_cdk'],
                      src_payload=metadata_dict['src_payload'],
                      src_hashdiff=metadata_dict['src_hashdiff'],
                      src_ldts=metadata_dict['src_ldts'],
                      src_source=metadata_dict['src_source'],
                      source_model=metadata_dict['source_model']) }}
