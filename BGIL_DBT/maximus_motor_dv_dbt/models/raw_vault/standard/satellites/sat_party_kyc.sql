-- Standard sat() for SAT_PARTY_KYC (parent HUB_PARTY, history SCD2), fed whole from central view stitch_mxm__v09_party.
-- WRITERS MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | SAT_PARTY_KYC | CKYC Number | None: emits CKYC_NUMBER; withheld CLAIM_CKYC_NUMBER
-- WRITERS MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | SAT_PARTY_KYC | CKYC Registration Status | None: emits CKYC_STATUS; withheld CLAIM_CKYC_STATUS, CLAIM_CKYC_STATUS_
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm__party_kyc'
src_pk:
  - 'PARTY_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'CKYC_NUMBER'
  - 'CKYC_REGISTRATION_STATUS'
  - 'KYC_COMPLETION_DATE'
  - 'KYC_STATUS'
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
