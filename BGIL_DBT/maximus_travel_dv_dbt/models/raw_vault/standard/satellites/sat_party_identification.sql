{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL sat_multi_source() for SAT_PARTY_IDENTIFICATION.
-- Writes the SAME physical table as the partner projects: separate projects, separate pipelines,
-- one shared vault. Same pattern as maximus_partner / opus_partner: one row per PARTY_HKEY and
-- source group, with AADHAARNUMBER / GSTIN / PANNUMBER / PASSPORTNUMBER / VOTERIDNUMBER / CKYCNUMBER
-- folded into OBJECTs keyed by source. Change detection and the watermark are per RECORD_SOURCE
-- group (MAXIMUS_TRAVEL), so other projects' rows are never touched.
--
-- One satfeed per stage (no UNION). Each satfeed appends the ID instance (IDENTIFICATION_TYPE_CODE)
-- to RECORD_SOURCE so every instance gets its own key inside the object columns.
-- The remaining columns are plain, as in the partner sats. IDENTIFICATIONNUMBER, IDENTIFICATIONISSUEDATE,
-- IDENTIFICATIONEXPIRYDATE, IDENTIFICATIONVERIFIEDINDICATOR and OVDCATEGORY are filled by several
-- instances in the uwr_pol_*_pp_sp_pv stages; for those only the MAX() value per party is kept.
-- IDENTIFICATION_TYPE_CODE is not a payload column: the type is carried in the object keys.

{%- set yaml_metadata -%}
source_model:
  - 'satfeed_mt_sat_party_identification__clm_clmd_clmap_pv'
  - 'satfeed_mt_sat_party_identification__clm_clmd_clmpty'
  - 'satfeed_mt_sat_party_identification__clm_clmd_clmrsk_party'
  - 'satfeed_mt_sat_party_identification__clm_clmd_clmrsk_rska_msp_msd_prop_pv'
  - 'satfeed_mt_sat_party_identification__uwr_pol_ins_mbr_pp_msp_msd_prop_pv'
  - 'satfeed_mt_sat_party_identification__uwr_pol_ins_mbr_pp_sp_pv'
  - 'satfeed_mt_sat_party_identification__uwr_pol_prp_pp_msp_msd_prop_pv'
  - 'satfeed_mt_sat_party_identification__uwr_pol_prp_pp_sp_pv'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'AADHAAR_NUMBER'
  - 'AADHAAR_VERIFICATION_STATUS'
  - 'AGE_PROOF_TYPE'
  - 'CIN_NUMBER'
  - 'CKYCNUMBER'
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
  - 'INSURANCEREPOSITORYNAME'
  - 'NREGA_CARD_NUMBER'
  - 'OVD_CATEGORY'
  - 'PAN_NUMBER'
  - 'PAN_VERIFICATION_STATUS'
  - 'PASSPORTEXPIRYDATE'
  - 'PASSPORT_NUMBER'
  - 'TAN_NUMBER'
  - 'VOTER_ID_NUMBER'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  satfeed_mt_sat_party_identification__clm_clmd_clmap_pv: 'MAXIMUS_TRAVEL'
  satfeed_mt_sat_party_identification__clm_clmd_clmpty: 'MAXIMUS_TRAVEL'
  satfeed_mt_sat_party_identification__clm_clmd_clmrsk_party: 'MAXIMUS_TRAVEL'
  satfeed_mt_sat_party_identification__clm_clmd_clmrsk_rska_msp_msd_prop_pv: 'MAXIMUS_TRAVEL'
  satfeed_mt_sat_party_identification__uwr_pol_ins_mbr_pp_msp_msd_prop_pv: 'MAXIMUS_TRAVEL'
  satfeed_mt_sat_party_identification__uwr_pol_ins_mbr_pp_sp_pv: 'MAXIMUS_TRAVEL'
  satfeed_mt_sat_party_identification__uwr_pol_prp_pp_msp_msd_prop_pv: 'MAXIMUS_TRAVEL'
  satfeed_mt_sat_party_identification__uwr_pol_prp_pp_sp_pv: 'MAXIMUS_TRAVEL'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ sat_multi_source(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model'],
                    src_record_source_map=metadata_dict['src_record_source_map'],
                    src_object_columns=['AADHAAR_NUMBER', 'GSTIN', 'PAN_NUMBER', 'PASSPORT_NUMBER', 'VOTER_ID_NUMBER', 'CKYCNUMBER'],
                    src_column_map={
                        'satfeed_mt_sat_party_identification__clm_clmd_clmap_pv': ['AADHAAR_NUMBER', 'AADHAAR_VERIFICATION_STATUS', 'AGE_PROOF_TYPE', 'CIN_NUMBER', 'CKYCNUMBER', 'DRIVING_LICENCE_EXPIRY_DATE', 'DRIVING_LICENCE_NUMBER', 'EIA_NUMBER', 'GSTIN', 'GST_REGISTRATION_STATUS', 'GST_TAXPAYER_TYPE', 'IDENTIFICATION_EXPIRY_DATE', 'IDENTIFICATION_ISSUE_DATE', 'IDENTIFICATION_ISSUING_AUTHORITY', 'IDENTIFICATION_NUMBER', 'IDENTIFICATION_VERIFIED_INDICATOR', 'INSURANCEREPOSITORYNAME', 'NREGA_CARD_NUMBER', 'OVD_CATEGORY', 'PAN_NUMBER', 'PAN_VERIFICATION_STATUS', 'PASSPORTEXPIRYDATE', 'PASSPORT_NUMBER', 'TAN_NUMBER', 'VOTER_ID_NUMBER'],
                        'satfeed_mt_sat_party_identification__clm_clmd_clmpty': ['AADHAAR_NUMBER', 'AADHAAR_VERIFICATION_STATUS', 'AGE_PROOF_TYPE', 'CIN_NUMBER', 'CKYCNUMBER', 'DRIVING_LICENCE_EXPIRY_DATE', 'DRIVING_LICENCE_NUMBER', 'EIA_NUMBER', 'GSTIN', 'GST_REGISTRATION_STATUS', 'GST_TAXPAYER_TYPE', 'IDENTIFICATION_EXPIRY_DATE', 'IDENTIFICATION_ISSUE_DATE', 'IDENTIFICATION_ISSUING_AUTHORITY', 'IDENTIFICATION_NUMBER', 'IDENTIFICATION_VERIFIED_INDICATOR', 'INSURANCEREPOSITORYNAME', 'NREGA_CARD_NUMBER', 'OVD_CATEGORY', 'PAN_NUMBER', 'PAN_VERIFICATION_STATUS', 'PASSPORTEXPIRYDATE', 'PASSPORT_NUMBER', 'TAN_NUMBER', 'VOTER_ID_NUMBER'],
                        'satfeed_mt_sat_party_identification__clm_clmd_clmrsk_party': ['AADHAAR_NUMBER', 'AADHAAR_VERIFICATION_STATUS', 'AGE_PROOF_TYPE', 'CIN_NUMBER', 'CKYCNUMBER', 'DRIVING_LICENCE_EXPIRY_DATE', 'DRIVING_LICENCE_NUMBER', 'EIA_NUMBER', 'GSTIN', 'GST_REGISTRATION_STATUS', 'GST_TAXPAYER_TYPE', 'IDENTIFICATION_EXPIRY_DATE', 'IDENTIFICATION_ISSUE_DATE', 'IDENTIFICATION_ISSUING_AUTHORITY', 'IDENTIFICATION_NUMBER', 'IDENTIFICATION_VERIFIED_INDICATOR', 'INSURANCEREPOSITORYNAME', 'NREGA_CARD_NUMBER', 'OVD_CATEGORY', 'PAN_NUMBER', 'PAN_VERIFICATION_STATUS', 'PASSPORTEXPIRYDATE', 'PASSPORT_NUMBER', 'TAN_NUMBER', 'VOTER_ID_NUMBER'],
                        'satfeed_mt_sat_party_identification__clm_clmd_clmrsk_rska_msp_msd_prop_pv': ['AADHAAR_NUMBER', 'AADHAAR_VERIFICATION_STATUS', 'AGE_PROOF_TYPE', 'CIN_NUMBER', 'CKYCNUMBER', 'DRIVING_LICENCE_EXPIRY_DATE', 'DRIVING_LICENCE_NUMBER', 'EIA_NUMBER', 'GSTIN', 'GST_REGISTRATION_STATUS', 'GST_TAXPAYER_TYPE', 'IDENTIFICATION_EXPIRY_DATE', 'IDENTIFICATION_ISSUE_DATE', 'IDENTIFICATION_ISSUING_AUTHORITY', 'IDENTIFICATION_NUMBER', 'IDENTIFICATION_VERIFIED_INDICATOR', 'INSURANCEREPOSITORYNAME', 'NREGA_CARD_NUMBER', 'OVD_CATEGORY', 'PAN_NUMBER', 'PAN_VERIFICATION_STATUS', 'PASSPORTEXPIRYDATE', 'PASSPORT_NUMBER', 'TAN_NUMBER', 'VOTER_ID_NUMBER'],
                        'satfeed_mt_sat_party_identification__uwr_pol_ins_mbr_pp_msp_msd_prop_pv': ['AADHAAR_NUMBER', 'AADHAAR_VERIFICATION_STATUS', 'AGE_PROOF_TYPE', 'CIN_NUMBER', 'CKYCNUMBER', 'DRIVING_LICENCE_EXPIRY_DATE', 'DRIVING_LICENCE_NUMBER', 'EIA_NUMBER', 'GSTIN', 'GST_REGISTRATION_STATUS', 'GST_TAXPAYER_TYPE', 'IDENTIFICATION_EXPIRY_DATE', 'IDENTIFICATION_ISSUE_DATE', 'IDENTIFICATION_ISSUING_AUTHORITY', 'IDENTIFICATION_NUMBER', 'IDENTIFICATION_VERIFIED_INDICATOR', 'INSURANCEREPOSITORYNAME', 'NREGA_CARD_NUMBER', 'OVD_CATEGORY', 'PAN_NUMBER', 'PAN_VERIFICATION_STATUS', 'PASSPORTEXPIRYDATE', 'PASSPORT_NUMBER', 'TAN_NUMBER', 'VOTER_ID_NUMBER'],
                        'satfeed_mt_sat_party_identification__uwr_pol_ins_mbr_pp_sp_pv': ['AADHAAR_NUMBER', 'AADHAAR_VERIFICATION_STATUS', 'AGE_PROOF_TYPE', 'CIN_NUMBER', 'CKYCNUMBER', 'DRIVING_LICENCE_EXPIRY_DATE', 'DRIVING_LICENCE_NUMBER', 'EIA_NUMBER', 'GSTIN', 'GST_REGISTRATION_STATUS', 'GST_TAXPAYER_TYPE', 'IDENTIFICATION_EXPIRY_DATE', 'IDENTIFICATION_ISSUE_DATE', 'IDENTIFICATION_ISSUING_AUTHORITY', 'IDENTIFICATION_NUMBER', 'IDENTIFICATION_VERIFIED_INDICATOR', 'INSURANCEREPOSITORYNAME', 'NREGA_CARD_NUMBER', 'OVD_CATEGORY', 'PAN_NUMBER', 'PAN_VERIFICATION_STATUS', 'PASSPORTEXPIRYDATE', 'PASSPORT_NUMBER', 'TAN_NUMBER', 'VOTER_ID_NUMBER'],
                        'satfeed_mt_sat_party_identification__uwr_pol_prp_pp_msp_msd_prop_pv': ['AADHAAR_NUMBER', 'AADHAAR_VERIFICATION_STATUS', 'AGE_PROOF_TYPE', 'CIN_NUMBER', 'CKYCNUMBER', 'DRIVING_LICENCE_EXPIRY_DATE', 'DRIVING_LICENCE_NUMBER', 'EIA_NUMBER', 'GSTIN', 'GST_REGISTRATION_STATUS', 'GST_TAXPAYER_TYPE', 'IDENTIFICATION_EXPIRY_DATE', 'IDENTIFICATION_ISSUE_DATE', 'IDENTIFICATION_ISSUING_AUTHORITY', 'IDENTIFICATION_NUMBER', 'IDENTIFICATION_VERIFIED_INDICATOR', 'INSURANCEREPOSITORYNAME', 'NREGA_CARD_NUMBER', 'OVD_CATEGORY', 'PAN_NUMBER', 'PAN_VERIFICATION_STATUS', 'PASSPORTEXPIRYDATE', 'PASSPORT_NUMBER', 'TAN_NUMBER', 'VOTER_ID_NUMBER'],
                        'satfeed_mt_sat_party_identification__uwr_pol_prp_pp_sp_pv': ['AADHAAR_NUMBER', 'AADHAAR_VERIFICATION_STATUS', 'AGE_PROOF_TYPE', 'CIN_NUMBER', 'CKYCNUMBER', 'DRIVING_LICENCE_EXPIRY_DATE', 'DRIVING_LICENCE_NUMBER', 'EIA_NUMBER', 'GSTIN', 'GST_REGISTRATION_STATUS', 'GST_TAXPAYER_TYPE', 'IDENTIFICATION_EXPIRY_DATE', 'IDENTIFICATION_ISSUE_DATE', 'IDENTIFICATION_ISSUING_AUTHORITY', 'IDENTIFICATION_NUMBER', 'IDENTIFICATION_VERIFIED_INDICATOR', 'INSURANCEREPOSITORYNAME', 'NREGA_CARD_NUMBER', 'OVD_CATEGORY', 'PAN_NUMBER', 'PAN_VERIFICATION_STATUS', 'PASSPORTEXPIRYDATE', 'PASSPORT_NUMBER', 'TAN_NUMBER', 'VOTER_ID_NUMBER']
                    }) }}
