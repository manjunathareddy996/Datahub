{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL ma_sat() for SAT_AUG_PARTY_IDENTIFICATION.
-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY this project's own
-- sources and only the payload it populates -- it does not union the sibling's models.
--
-- The sibling does not build this satellite, so this build ESTABLISHES its contract
-- (BUILD_RULES 7.3): bare HASHDIFF, PARTY_HKEY, multi-active on IDENTIFICATION_TYPE_CODE.

{%- set yaml_metadata -%}
source_model: 'satfeed_mt_aug_sat_aug_party_identification'
src_pk: 'PARTY_HKEY'
src_cdk:
  - 'IDENTIFICATION_TYPE_CODE'
src_payload:
  - 'EIA_CREDIT_REQUIRED_INDICATOR'
  - 'EIA_DETAILS_NARRATIVE'
  - 'EIA_HELD_INDICATOR'
  - 'EIA_LINKED_DATE'
  - 'EIA_REQUIRED_INDICATOR'
  - 'IDENTIFICATION_DETAILS_NARRATIVE'
  - 'IDENTIFICATION_VERIFICATION_STATUS'
  - 'NAME_AS_PER_IDENTIFICATION_DOCUMENT'
  - 'OVD_CATEGORY_OTHER_DESCRIPTION'
  - 'PAN_AADHAAR_LINKED_INDICATOR'
  - 'PASSPORT_DETAIL_DESCRIPTION'
  - 'PASSPORT_FILE_NUMBER'
  - 'PASSPORT_ISSUING_COUNTRY'
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
