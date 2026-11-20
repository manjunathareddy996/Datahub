-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_PARTY_KYC (parent HUB_PARTY, history SCD2), fed whole from central view stitch_mxm__v09_party.
-- WRITERS MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | SAT_MOTOR_AUG_PARTY_KYC | CKYC Detail Text | None: emits CKYC_DETAILS; withheld CLAIM_CKYC_DETAILS
-- WRITERS MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | SAT_MOTOR_AUG_PARTY_KYC | KYC Detail Text | None: emits KYC_DETAILS; withheld KYC_RELATED_DETAILS
-- WRITERS MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | SAT_MOTOR_AUG_PARTY_KYC | Proof Of Address Status | None: emits POA_STATUS; withheld CLAIM_POA_STATUS
-- WRITERS MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | SAT_MOTOR_AUG_PARTY_KYC | Proof Of Identity Status | None: emits POI_STATUS; withheld CLAIM_POI_STATUS
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__party_kyc'
src_pk:
  - 'PARTY_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'CKYC_DETAIL_TEXT'
  - 'CKYC_NUMBER_HELD_INDICATOR'
  - 'KYC_DETAIL_TEXT'
  - 'OPTIONAL_SUPPORTING_PROOF_DOCUMENT_TYPE'
  - 'PRIMARY_SUPPORTING_PROOF_DOCUMENT_TYPE'
  - 'PROOF_OF_ADDRESS_DOCUMENT_TYPE'
  - 'PROOF_OF_ADDRESS_STATUS'
  - 'PROOF_OF_ADDRESS_VERIFICATION_STATUS'
  - 'PROOF_OF_IDENTITY_DOCUMENT_TYPE'
  - 'PROOF_OF_IDENTITY_STATUS'
  - 'PROOF_OF_IDENTITY_VERIFICATION_STATUS'
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
