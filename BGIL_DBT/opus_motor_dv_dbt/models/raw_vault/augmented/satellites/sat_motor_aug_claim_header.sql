-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_CLAIM_HEADER (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_motor__v01_claim.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__claim_header'
src_pk:
  - 'CLAIM_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'CLAIM_OBSERVATION_TEXT'
  - 'CONTACT_PERSON_NAME'
  - 'DIGITAL_REGISTRATION_INDICATOR'
  - 'DOCUMENT_CHECK_BY_REFERENCE'
  - 'DOCUMENT_CHECK_DATE'
  - 'DOCUMENT_RECEIVED_DATE'
  - 'DOCUMENT_VERIFIED_BY_REFERENCE'
  - 'DOCUMENT_VERIFIED_DATE'
  - 'FAST_TRACK_FLAG_CHANGED_BY_REFERENCE'
  - 'FAST_TRACK_FLAG_CHANGED_DATE'
  - 'FLAG_SET_DATE'
  - 'FPLM_INDICATOR'
  - 'FPLM_REASON'
  - 'HOUSEHOLD_IDENTIFIER'
  - 'LIABILITY_SMS_SENT_INDICATOR'
  - 'LOSS_EVENT_CODE'
  - 'NCB_ENDORSEMENT_NUMBER'
  - 'OTHER_INTIMATION_CHANNEL_DESCRIPTION'
  - 'OTHER_REASON_TEXT'
  - 'POLICY_YEAR_OF_CLAIM'
  - 'PROCESSOR_REMARKS'
  - 'REGISTERING_USER_TYPE'
  - 'RELATED_ENDORSEMENT_APPROVED_INDICATOR'
  - 'RELATED_ENDORSEMENT_VERSION'
  - 'SUPPLEMENTARY_CLAIM_REFERENCE'
  - 'UNQUALIFIED_REASON_TEXT'
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
