-- Standard ma_sat() for SAT_PARTY_IDENTIFICATION (parent HUB_PARTY, history Multi-Active SCD2), fed whole from central view stitch_v10_party.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_party_identification'
src_pk: 'PARTY_HKEY'
src_cdk:
  - 'IDENTIFICATION_TYPE_CODE_CK'
src_payload:
  - 'AADHAAR_NUMBER'
  - 'AADHAAR_VERIFICATION_STATUS'
  - 'AGE_PROOF_TYPE'
  - 'CIN_NUMBER'
  - 'DRIVING_LICENCE_EXPIRY_DATE'
  - 'DRIVING_LICENCE_NUMBER'
  - 'EIA_NUMBER'
  - 'GSTIN'
  - 'GST_REGISTRATION_STATUS'
  - 'GST_TAXPAYER_TYPE'
  - 'IDENTIFICATION_EXPIRY_DATE'
  - 'IDENTIFICATION_ISSUE_DATE'
  - 'IDENTIFICATION_ISSUING_AUTHORITY'
  - 'IDENTIFICATION_NUMBER'
  - 'IDENTIFICATION_TYPE_CODE'
  - 'IDENTIFICATION_VERIFIED_INDICATOR'
  - 'NREGA_CARD_NUMBER'
  - 'OVD_CATEGORY'
  - 'PAN_NUMBER'
  - 'PAN_VERIFICATION_STATUS'
  - 'PASSPORT_NUMBER'
  - 'TAN_NUMBER'
  - 'VOTER_ID_NUMBER'
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
