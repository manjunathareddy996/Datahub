-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_AUG_PARTY_IDENTIFICATION (parent HUB_PARTY, history SCD2), fed whole from central view stitch_v10_party.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_party_identification'
src_pk: 'PARTY_HKEY'
src_cdk:
  - 'IDENTIFICATION_TYPE_CODE_CK'
src_payload:
  - 'CLAIM_CONTEXT_IDENTIFICATION_VERIFIED_INDICATOR'
  - 'EIA_AVAILABLE_INDICATOR'
  - 'EIA_CREDIT_REQUIRED_INDICATOR'
  - 'EIA_DETAILS_DESCRIPTION'
  - 'EIA_REQUIRED_INDICATOR'
  - 'NAME_AS_PER_IDENTIFICATION_DOCUMENT'
  - 'PAN_AADHAAR_LINKED_INDICATOR'
  - 'PAN_APPLICATION_NUMBER'
  - 'PAN_APPLIED_INDICATOR'
  - 'PASSPORT_DETAIL_DESCRIPTION'
  - 'PASSPORT_FILE_NUMBER'
  - 'PROOF_OF_ADDRESS_OTHER_DESCRIPTION'
  - 'STATE_WISE_GSTIN_REGISTRATION_DETAILS'
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
