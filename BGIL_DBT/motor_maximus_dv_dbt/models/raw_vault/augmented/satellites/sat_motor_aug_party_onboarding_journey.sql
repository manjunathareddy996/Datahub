-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_PARTY_ONBOARDING_JOURNEY (parent HUB_PARTY, history SCD2), fed whole from central view stitch_mxm__v09_party.
-- WRITERS MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | SAT_MOTOR_AUG_PARTY_ONBOARDING_JOURNEY | Licence Examination Detail Text | None: emits EXAMINATIONS_DETAILS_FOR_IRDA_CODE; withheld EXAM_DETAILS
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__party_onboarding_journey'
src_pk:
  - 'PARTY_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'CANDIDATE_BACKGROUND_DESCRIPTION'
  - 'INSURANCE_BANKING_FINANCE_EXPERIENCE_YEARS'
  - 'LICENCE_EXAMINATION_DETAIL_TEXT'
  - 'PREVIOUS_EMPLOYER_LOCATION'
  - 'PREVIOUS_EMPLOYER_PARENT_INTERMEDIARY_CODE'
  - 'PREVIOUS_EMPLOYER_PARENT_SUB_INTERMEDIARY_CODE'
  - 'PREVIOUS_EMPLOYMENT_LEAVING_REASON'
  - 'PREVIOUS_NON_GENERAL_INSURER_NAME'
  - 'REJECTION_REASON'
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
