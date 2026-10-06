{{ config(materialized='incremental') }}

-- PARTNER STANDARD-MODEL hub() for HUB_PARTY.
-- CP_PARTNERS holds every partner_id, so a single cp_partners branch is the
-- authoritative source for the full HUB_PARTY key set. The previous per-table
-- hub stages were redundant against this and have been removed.
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
