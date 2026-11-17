-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_AUG_CLAIM_THIRD_PARTY_LINE (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_motor__v01_claim.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__claim_third_party_line'
src_pk: 'CLAIM_HKEY'
src_cdk:
  - 'INJURED_PARTY_SEQUENCE_CK'
src_payload:
  - 'DAMAGED_OBJECT'
  - 'DAMAGED_OBJECT_DESCRIPTION'
  - 'DAMAGE_DESCRIPTION'
  - 'DAMAGE_KIND'
  - 'DISABILITY_TYPE'
  - 'INJURED_PARTY_SEQUENCE'
  - 'INJURY_DETAILS'
  - 'INJURY_TYPE'
  - 'PERIOD_OF_DISABLEMENT'
  - 'THIRD_PARTY_DRIVER_LICENCE_EXPIRY_DATE'
  - 'THIRD_PARTY_DRIVER_LICENCE_NUMBER'
  - 'THIRD_PARTY_INSURER_BRANCH'
  - 'THIRD_PARTY_INSURER_CONTACT_NUMBER'
  - 'THIRD_PARTY_INSURER_NAME'
  - 'THIRD_PARTY_INSURER_POLICY_NUMBER'
  - 'VICTIM_ADDRESS_TEXT'
  - 'VICTIM_AGE'
  - 'VICTIM_DECLARED_INCOME'
  - 'VICTIM_GENDER_CODE'
  - 'VICTIM_NAME'
  - 'VICTIM_OCCUPATION'
  - 'WORK_CEASED_DATE'
  - 'WORK_RESUMED_DATE'
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
