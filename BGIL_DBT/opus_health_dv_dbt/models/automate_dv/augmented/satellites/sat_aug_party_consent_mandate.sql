-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_PARTY_CONSENT_MANDATE (parent HUB_PARTY, history SCD2), fed whole from central view stitch_v16_party.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_party_consent_mandate'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'MANDATE_APPROVAL_STATUS'
  - 'MANDATE_APPROVED_BY_REFERENCE'
  - 'MANDATE_APPROVED_DATE'
  - 'MANDATE_HEAD_OFFICE_ENABLED_BY_REFERENCE'
  - 'MANDATE_HEAD_OFFICE_ENABLED_DATE'
  - 'MANDATE_REJECTION_REASON_CODE'
  - 'MANDATE_REJECTION_REASON_OTHER_TEXT'
  - 'MANDATE_REQUESTED_BY_REFERENCE'
  - 'MANDATE_REQUESTED_DATE'
  - 'MANDATE_RESPONSIBLE_APPROVER_REFERENCE'
  - 'MANDATE_UPDATE_REQUEST_REASON'
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
