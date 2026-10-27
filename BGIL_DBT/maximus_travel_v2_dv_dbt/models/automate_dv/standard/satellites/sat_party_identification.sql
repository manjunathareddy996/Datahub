{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL V2 ma_sat() for SAT_PARTY_IDENTIFICATION.
-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY this project's own
-- sources and only the payload it populates -- it does not union the sibling's models.
--
-- src_pk, grain and src_cdk are the SIBLING's exactly (BUILD_RULES 7.2 / 7.7). The
-- sibling builds this satellite on its standard track; where this map asks for a grain
-- the sibling does not carry, the SIBLING WINS and the difference is a modeller item
-- in the build report -- it is not resolved here.

{%- set yaml_metadata -%}
source_model:
  - 'satfeed_mtv2_sat_party_identification'
src_pk: 'PARTY_HKEY'
src_cdk:
  - 'IDENTIFICATION_TYPE_CODE'
src_payload:
  - 'AADHAAR_NUMBER'
  - 'AADHAAR_VERIFICATION_STATUS'
  - 'AGE_PROOF_TYPE'
  - 'CIN_NUMBER'
  - 'CKYC_NUMBER'
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
  - 'IDENTIFICATION_VERIFIED_INDICATOR'
  - 'INSURANCE_REPOSITORY_NAME'
  - 'NREGA_CARD_NUMBER'
  - 'OVD_CATEGORY'
  - 'PAN_NUMBER'
  - 'PAN_VERIFICATION_STATUS'
  - 'PASSPORT_EXPIRY_DATE'
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
