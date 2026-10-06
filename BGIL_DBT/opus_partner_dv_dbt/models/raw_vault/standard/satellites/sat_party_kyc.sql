{{
    config(
        materialized='incremental',
        incremental_strategy='append',
    )
}}

-- PARTNER+KYC STANDARD-MODEL sat() for SAT_PARTY_KYC (HUB_PARTY grain) -- union of 5 branch(es).
-- data_7: hist 'SCD2', childkey '', anchor parent 'HUB_PARTY'.
-- Payload rendered GLUED (DEC-01, anchor kind HUB read from data_7's parent field).
--
-- KNOWN DESTRUCTIVE OVERWRITE, BUILT AS MAPPED AND RAISED (5.7). 1 attribute(s)
-- of this SINGLE-ACTIVE satellite are written by more than one source table
-- under a byte-identical HUB_PARTY key with an EMPTY discriminator, so whichever
-- branch loads last wins: KYC Completion Date.
-- The builder refuses to invent a discriminator. One modeller answer unblocks it.
--
-- opus_partner_dv_dbt: written in this project's pattern -- incremental append, sat_multi_source, src_record_source_map OPUS, src_column_map per source; source_model listed once each.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_sat_bjaz_t_ckyc_personal_dtls__party_kyc'
  - 'stg2_sat_bjaz_t_ckyc_rel_persion_dtls__party_kyc__related_person'
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
  stg2_sat_bjaz_t_ckyc_personal_dtls__party_kyc: 'OPUS'
  stg2_sat_bjaz_t_ckyc_rel_persion_dtls__party_kyc__related_person: 'OPUS'
  stg2_sat_bjaz_t_ckyc_search__party_kyc: 'OPUS'
  stg2_sat_bjaz_t_kyc_details__party_kyc: 'OPUS'
  stg2_sat_bjaz_t_kyc_incoming__party_kyc: 'OPUS'
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
                        'stg2_sat_bjaz_t_ckyc_personal_dtls__party_kyc': ['KYCTYPE', 'OVDSUBMITTEDCOUNT'],
                        'stg2_sat_bjaz_t_ckyc_rel_persion_dtls__party_kyc__related_person': ['KYCCOMPLETIONDATE'],
                        'stg2_sat_bjaz_t_ckyc_search__party_kyc': ['CKYCNUMBER', 'CKYCREGISTRATIONSTATUS', 'KYCCOMPLETIONDATE', 'LASTKYCREVIEWDATE'],
                        'stg2_sat_bjaz_t_kyc_details__party_kyc': ['KYCCOMPLETIONDATE', 'KYCSTATUS'],
                        'stg2_sat_bjaz_t_kyc_incoming__party_kyc': ['KYCMODE', 'KYCTYPE']
                    }) }}
