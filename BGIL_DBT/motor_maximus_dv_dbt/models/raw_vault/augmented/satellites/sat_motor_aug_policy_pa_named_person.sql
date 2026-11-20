-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_MOTOR_AUG_POLICY_PA_NAMED_PERSON (parent HUB_POLICY, history SCD2), fed whole from central view stitch_mxm__v13_policy.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__policy_pa_named_person'
src_pk:
  - 'POLICY_HKEY'
  - 'SOURCE_SYSTEM'
src_cdk:
  - 'NAMED_PERSON_NAME_CK'
  - 'NAMED_PERSON_SEQUENCE_CK'
src_payload:
  - 'BENEFIT_ALLOCATION_PERCENTAGE'
  - 'NAMED_PERSON_AGE'
  - 'NAMED_PERSON_GENDER'
  - 'NAMED_PERSON_NAME'
  - 'NAMED_PERSON_RELATIONSHIP'
  - 'NOMINEE_NAME'
  - 'NOMINEE_RELATIONSHIP_TO_INSURED'
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
