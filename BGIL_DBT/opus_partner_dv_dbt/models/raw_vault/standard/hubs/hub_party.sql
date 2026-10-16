{{ config(materialized='incremental') }}

-- PARTNER STANDARD-MODEL hub() for HUB_PARTY.
-- CP_PARTNERS is the primary partner_id branch, but it is NOT the complete key
-- set: AZBJ_PARTNER_EXTN carries ~45.6k part_ids not in CP_PARTNERS, and
-- BJAZ_INTERMEDIARY contributes intermediary parties on PARTNER_ID. Both are
-- added below (DM-R1 item 6 fix) so party-grain satellites keyed from those
-- tables have a parent hub row.
-- KYC: 17 KYC feeds added below. They key the KYC SUBJECT (CKYC:/PAN:/GSTIN:/
-- LICENCE:/PASSPORT:/VOTER:/CATEGORY:INPUT forms), a separate key space from
-- cp_partners' part_id, so KYC parties are new HUB_PARTY rows, not partner rows.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_hub_cp_partners__party'
  - 'stg2_hub_bjaz_m_kyc_driving_licence__party'
  - 'stg2_hub_bjaz_m_kyc_gstn__party'
  - 'stg2_hub_bjaz_m_kyc_pan__party'
  - 'stg2_hub_bjaz_m_kyc_passport__party'
  - 'stg2_hub_bjaz_m_kyc_voter__party'
  - 'stg2_hub_bjaz_t_ckyc_otp__party'
  - 'stg2_hub_bjaz_t_ckyc_personal_dtls__party'
  - 'stg2_hub_bjaz_t_ckyc_rel_persion_dtls__party'
  - 'stg2_hub_bjaz_t_ckyc_search__party'
  - 'stg2_hub_bjaz_t_ekyc__party'
  - 'stg2_hub_bjaz_t_kyc_auth__party'
  - 'stg2_hub_bjaz_t_kyc_details__party'
  - 'stg2_hub_bjaz_t_kyc_incoming__party'
  - 'stg2_hub_bjaz_t_kyc_name_match__party'
  - 'stg2_hub_bjaz_t_kyc_ocr__party'
  - 'stg2_hub_bjaz_t_kyc_poa_document__party'
  - 'stg2_hub_bjaz_t_kyc_poi_document__party'
src_pk: 'PARTY_HKEY'
src_nk: 'PARENT_BK'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.hub(src_pk=metadata_dict['src_pk'],
                    src_nk=metadata_dict['src_nk'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
