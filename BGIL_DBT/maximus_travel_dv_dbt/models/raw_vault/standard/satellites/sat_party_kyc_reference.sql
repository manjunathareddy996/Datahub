{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL ma_sat_multi_source() for SAT_PARTY_KYC_REFERENCE.
-- Writes the SAME physical table as opus_partner: separate projects, separate pipelines, one shared
-- vault. Grain is unchanged: PARTY_HKEY, multi-active on the KYC reference type (PROOF_OF_ADDRESS /
-- PROOF_OF_IDENTITY), bare HASHDIFF.
--
-- ma_sat_multi_source groups change detection by (PARTY_HKEY, RECORD_SOURCE) and takes the watermark
-- from MAX(DBT_RUN_TS) of MAXIMUS_TRAVEL_* rows only, so this project never compares against the
-- opus_partner rows (single-active, sat_multi_source) on the shared table.
-- One satfeed per stage (no UNION).

{%- set yaml_metadata -%}
source_model:
  - 'satfeed_mt_sat_party_kyc_reference__uwr_pol_ins_mbr_pp_sp_pv'
  - 'satfeed_mt_sat_party_kyc_reference__uwr_pol_prp_pp_sp_pv'
src_pk: 'PARTY_HKEY'
src_cdk:
  - 'KYCREFERENCETYPE'
src_payload:
  - 'VERIFICATION_STATUS'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  satfeed_mt_sat_party_kyc_reference__uwr_pol_ins_mbr_pp_sp_pv: 'MAXIMUS_TRAVEL'
  satfeed_mt_sat_party_kyc_reference__uwr_pol_prp_pp_sp_pv: 'MAXIMUS_TRAVEL'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ ma_sat_multi_source(src_pk=metadata_dict['src_pk'],
                       src_cdk=metadata_dict['src_cdk'],
                       src_payload=metadata_dict['src_payload'],
                       src_hashdiff=metadata_dict['src_hashdiff'],
                       src_ldts=metadata_dict['src_ldts'],
                       src_source=metadata_dict['src_source'],
                       source_model=metadata_dict['source_model'],
                       src_record_source_map=metadata_dict['src_record_source_map'],
                       src_column_map={
                        'satfeed_mt_sat_party_kyc_reference__uwr_pol_ins_mbr_pp_sp_pv': ['VERIFICATION_STATUS'],
                        'satfeed_mt_sat_party_kyc_reference__uwr_pol_prp_pp_sp_pv': ['VERIFICATION_STATUS']
                       }) }}
