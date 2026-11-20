-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_MOTOR_AUG_PARTY_IDENTIFICATION (parent HUB_PARTY, history SCD2), fed whole from central view stitch_mxm__v09_party.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__party_identification'
src_pk:
  - 'PARTY_HKEY'
  - 'SOURCE_SYSTEM'
src_cdk:
  - 'IDENTIFICATION_TYPE_CODE_CK'
src_payload:
  - 'AADHAAR_ENROLMENT_NUMBER'
  - 'AADHAAR_VIRTUAL_IDENTIFIER'
  - 'ABHA_NUMBER'
  - 'DRIVING_LICENCE_DETAIL_TEXT'
  - 'DRIVING_LICENCE_TYPE'
  - 'EIA_AVAILABLE_INDICATOR'
  - 'EIA_DETAIL_TEXT'
  - 'EIA_LINKAGE_DATE'
  - 'EIA_POLICY_CREDIT_REQUIRED_INDICATOR'
  - 'EIA_REQUIRED_INDICATOR'
  - 'GST_COMPOSITION_SCHEME_INDICATOR'
  - 'GST_PAYABLE_INDICATOR'
  - 'IDENTIFICATION_ISSUING_COUNTRY'
  - 'IDENTIFICATION_PLACE_OF_ISSUE'
  - 'IDENTIFICATION_VALID_FROM_DATE'
  - 'NAME_AS_PER_IDENTIFICATION_DOCUMENT'
  - 'PAN_AADHAAR_LINKED_INDICATOR'
  - 'PASSPORT_DETAIL_TEXT'
  - 'PASSPORT_FILE_NUMBER'
  - 'PROOF_OF_ADDRESS_STATUS'
  - 'PROOF_OF_IDENTITY_STATUS'
  - 'STATE_WISE_GSTIN_DETAIL_TEXT'
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
