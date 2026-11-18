{{ config(materialized='incremental') }}

-- MAXIMUS PARTNER sat() for SAT_PARTY_IDENTIFICATION.
-- Writes the SAME physical table as partner_dv_dbt's model of the same name: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY Maximus's sources and only the
-- payload Maximus populates, which is what removes any need to back-patch the other project.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_mp__pd_prop_msdp_pv'
  - 'stg2_mp__pd_prop_sp_pv'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'AADHAAR_NUMBER'
  - 'AADHAAR_VERIFICATION_STATUS'
  - 'AGE_PROOF_TYPE'
  - 'CIN_NUMBER'
  - 'DRIVING_LICENCE_EXPIRY_DATE'
  - 'DRIVING_LICENCE_NUMBER'
  - 'EIA_NUMBER'
  - 'FORM60INDICATOR'
  - 'GSTIN'
  - 'GST_REGISTRATION_STATUS'
  - 'GST_TAXPAYER_TYPE'
  - 'IDENTIFICATION_EXPIRY_DATE'
  - 'IDENTIFICATION_ISSUE_DATE'
  - 'IDENTIFICATION_ISSUING_AUTHORITY'
  - 'IDENTIFICATION_NUMBER'
  - 'IDENTIFICATION_TYPE_CODE'
  - 'IDENTIFICATION_VERIFIED_INDICATOR'
  - 'INSURANCEREPOSITORYNAME'
  - 'NREGA_CARD_NUMBER'
  - 'OVD_CATEGORY'
  - 'PAN_NUMBER'
  - 'PAN_VERIFICATION_STATUS'
  - 'PASSPORTEXPIRYDATE'
  - 'PASSPORT_NUMBER'
  - 'TAN_NUMBER'
  - 'VOTER_ID_NUMBER'
  - 'CKYCNUMBER'
src_hashdiff: 'HASHDIFF_PARTY_IDENTIFICATION'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  stg2_mp__pd_prop_msdp_pv: 'MAXIMUS_PARTNER'
  stg2_mp__pd_prop_sp_pv: 'MAXIMUS_PARTNER'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ sat_multi_source(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_hashdiff_alias='HASHDIFF',
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model'],
                    src_record_source_map=metadata_dict['src_record_source_map'],
                    src_object_columns=['AADHAAR_NUMBER', 'GSTIN', 'PAN_NUMBER', 'PASSPORT_NUMBER', 'VOTER_ID_NUMBER', 'CKYCNUMBER'],
                    src_column_map={
                        'stg2_mp__pd_prop_msdp_pv': ['IDENTIFICATION_ISSUE_DATE', 'PASSPORTEXPIRYDATE', 'PASSPORT_NUMBER'],
                        'stg2_mp__pd_prop_sp_pv': ['AADHAAR_NUMBER', 'AADHAAR_VERIFICATION_STATUS', 'AGE_PROOF_TYPE', 'CIN_NUMBER', 'CKYCNUMBER', 'DRIVING_LICENCE_EXPIRY_DATE', 'DRIVING_LICENCE_NUMBER', 'EIA_NUMBER', 'FORM60INDICATOR', 'GSTIN', 'GST_REGISTRATION_STATUS', 'GST_TAXPAYER_TYPE', 'IDENTIFICATION_EXPIRY_DATE', 'IDENTIFICATION_ISSUE_DATE', 'IDENTIFICATION_ISSUING_AUTHORITY', 'IDENTIFICATION_NUMBER', 'IDENTIFICATION_TYPE_CODE', 'IDENTIFICATION_VERIFIED_INDICATOR', 'INSURANCEREPOSITORYNAME', 'NREGA_CARD_NUMBER', 'OVD_CATEGORY', 'PAN_NUMBER', 'PAN_VERIFICATION_STATUS', 'PASSPORTEXPIRYDATE', 'PASSPORT_NUMBER', 'TAN_NUMBER', 'VOTER_ID_NUMBER']
                    }) }}
