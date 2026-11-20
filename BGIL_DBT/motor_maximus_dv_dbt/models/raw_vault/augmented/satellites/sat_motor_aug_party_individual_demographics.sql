-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS (parent HUB_PARTY, history SCD2), fed whole from central view stitch_mxm__v09_party.
-- WRITERS MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | SAT_MOTOR_AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS | Mother Maiden Name | None: emits MOTHERS_MAIDEN_NAME; withheld MOTHER_MAIDEN_NAME
-- WRITERS MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | SAT_MOTOR_AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS | Qualification Detail Text | None: emits QUALIFICATIONS_DETAILS; withheld QUALIFICATION_DETAILS
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__party_individual_demographics'
src_pk:
  - 'PARTY_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'BASIC_QUALIFICATION_BOARD_NAME'
  - 'BASIC_QUALIFICATION_DETAIL_TEXT'
  - 'BASIC_QUALIFICATION_ROLL_NUMBER'
  - 'DATE_OF_MARRIAGE'
  - 'FATHER_OR_SPOUSE_NAME'
  - 'IRDAI_LISTED_PRIMARY_PROFESSION'
  - 'MOTHER_MAIDEN_NAME'
  - 'NUMBER_OF_DAUGHTERS'
  - 'NUMBER_OF_SONS'
  - 'OTHER_OCCUPATION_DESCRIPTION'
  - 'OTHER_QUALIFICATION'
  - 'PRIMARY_PROFESSION'
  - 'PROFESSIONAL_QUALIFICATION'
  - 'QUALIFICATION_DETAIL_TEXT'
  - 'QUALIFICATION_PASSING_MONTH'
  - 'QUALIFICATION_PASSING_YEAR'
  - 'UNDERGRADUATE_QUALIFICATION'
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
