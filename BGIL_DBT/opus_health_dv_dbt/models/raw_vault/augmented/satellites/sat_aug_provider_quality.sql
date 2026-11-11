-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_PROVIDER_QUALITY (parent HUB_PARTY, history SCD2), fed whole from central view stitch_v15_party.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_provider_quality'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'AVERAGE_ADMISSION_TIME'
  - 'AVERAGE_DISCHARGE_TIME'
  - 'AVERAGE_LENGTH_OF_STAY_MEDICAL'
  - 'AVERAGE_LENGTH_OF_STAY_SURGICAL'
  - 'BED_OCCUPANCY_RATE'
  - 'CAESAREAN_SECTION_RATE'
  - 'DOCTOR_TO_BED_RATIO'
  - 'DOCTOR_TO_PATIENT_RATIO'
  - 'NURSE_TO_BED_RATIO'
  - 'NURSE_TO_PATIENT_RATIO'
  - 'PROVIDER_CONFIGURED_DATE'
  - 'PROVIDER_RECORD_FLAG'
  - 'PROVIDER_RECORD_LAST_UPDATED_BY_USER_REFERENCE'
  - 'PROVIDER_REMARKS'
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
