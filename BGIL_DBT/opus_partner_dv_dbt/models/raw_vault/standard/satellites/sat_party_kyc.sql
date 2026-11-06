{{
    config(
        materialized='incremental',
        incremental_strategy='append',
    )
}}

-- PARTNER+KYC STANDARD-MODEL sat() for SAT_PARTY_KYC (HUB_PARTY grain), keyed on part_id.
--
-- PARTY KEY: every branch resolves part_id through BJAZ_T_KYC_DETAILS (the only KYC table
-- that carries the partner, on rows where FIELD_TYPE = partner field type and FIELD_VALUE =
-- part_id) and hashes 'HUB_PARTY|' || part_id -- the same key as stg2_hub_cp_partners__party.
--   BJAZ_T_KYC_DETAILS   own partner row, else POI_DOC_ID   (stage_kyc__bjaz_t_kyc_details)
--   BJAZ_T_CKYC_SEARCH   SEARCH_ID                         (stage_kyc__bjaz_t_ckyc_search)
--   BJAZ_T_KYC_INCOMING  INCOMING_ID                       (stage_kyc__bjaz_t_kyc_incoming)
--
-- PENDING, NOT LOADED UNTIL THEIR JOIN IS CONFIRMED (they still carry the old CKYC: key,
-- which has no HUB_PARTY row):
--   stg2_sat_bjaz_t_ckyc_personal_dtls__party_kyc                    (KYCTYPE, OVDSUBMITTEDCOUNT)
--   stg2_sat_bjaz_t_ckyc_rel_persion_dtls__party_kyc__related_person (KYCCOMPLETIONDATE)
--
-- KNOWN OVERWRITE: KYC Completion Date is written by CKYC_SEARCH and KYC_DETAILS under the
-- same PARTY_HKEY; RECORD_SOURCE keeps them as separate histories.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_sat_bjaz_t_ckyc_search__party_kyc'
  - 'stg2_sat_bjaz_t_kyc_details__party_kyc'
  - 'stg2_sat_bjaz_t_kyc_incoming__party_kyc'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'CKYCNUMBER'
  - 'CKYCREGISTRATIONSTATUS'
  - 'KYCCOMPLETIONDATE'
  - 'KYCMODE'
  - 'KYCSTATUS'
  - 'KYCTYPE'
  - 'LASTKYCREVIEWDATE'
  - 'OVDSUBMITTEDCOUNT'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  stg2_sat_bjaz_t_ckyc_search__party_kyc: 'OPUS_PARTNER'
  stg2_sat_bjaz_t_kyc_details__party_kyc: 'OPUS_PARTNER'
  stg2_sat_bjaz_t_kyc_incoming__party_kyc: 'OPUS_PARTNER'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ sat_multi_source(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model'],
                    src_record_source_map=metadata_dict['src_record_source_map'],
                    src_column_map={
                        'stg2_sat_bjaz_t_ckyc_search__party_kyc': ['CKYCNUMBER', 'CKYCREGISTRATIONSTATUS', 'KYCCOMPLETIONDATE', 'LASTKYCREVIEWDATE'],
                        'stg2_sat_bjaz_t_kyc_details__party_kyc': ['KYCCOMPLETIONDATE', 'KYCSTATUS'],
                        'stg2_sat_bjaz_t_kyc_incoming__party_kyc': ['KYCMODE', 'KYCTYPE']
                    }) }}
