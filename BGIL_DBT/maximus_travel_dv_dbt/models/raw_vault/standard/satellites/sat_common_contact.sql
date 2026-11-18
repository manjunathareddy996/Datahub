{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL sat_multi_source() for SAT_COMMON_CONTACT.
-- Writes the SAME physical table as the partner projects: separate projects, separate pipelines,
-- one shared vault. Same pattern as maximus_partner / opus_partner: one row per PARTY_HKEY and
-- source group, with MOBILENUMBER folded into an OBJECT keyed by source. Change detection and the
-- watermark are per RECORD_SOURCE group (MAXIMUS_TRAVEL), so other projects' rows are never touched.
--
-- One satfeed per stage (no UNION). Each satfeed appends the contact instance (CONTACT_POINT_TYPE)
-- to RECORD_SOURCE so every instance gets its own key inside the MOBILENUMBER object.
-- EMAILADDRESS / LANDLINENUMBER / SOCIALMEDIAHANDLE are plain columns, as in the partner sats: when a
-- party has several of them in one stage, only the MAX() value is kept.
-- CONTACT_POINT_USAGE is travel-only (alternate mobile "belongs to"); append_new_columns adds it.

{%- set yaml_metadata -%}
source_model:
  - 'satfeed_mt_sat_common_contact__clm_clmd_clmap_pv'
  - 'satfeed_mt_sat_common_contact__clm_clmd_clmrsk_rska_properties_pv'
  - 'satfeed_mt_sat_common_contact__uwr_pol_ins_mbr_pa'
  - 'satfeed_mt_sat_common_contact__uwr_pol_ins_mbr_pa_address_prop_pv'
  - 'satfeed_mt_sat_common_contact__uwr_pol_ins_mbr_pp_sp_pv'
  - 'satfeed_mt_sat_common_contact__uwr_pol_prp_pa'
  - 'satfeed_mt_sat_common_contact__uwr_pol_prp_pa_address_prop_pv'
  - 'satfeed_mt_sat_common_contact__uwr_pol_prp_pp_sp_pv'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'ALTERNATE_EMAIL_ADDRESS'
  - 'ALTERNATE_MOBILE_NUMBER'
  - 'CONTACT_POINT_USAGE'
  - 'EMAIL_ADDRESS'
  - 'FAX_NUMBER'
  - 'LANDLINE_NUMBER'
  - 'MOBILE_NUMBER'
  - 'SOCIALMEDIAHANDLE'
  - 'STD_CODE'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  satfeed_mt_sat_common_contact__clm_clmd_clmap_pv: 'MAXIMUS_TRAVEL'
  satfeed_mt_sat_common_contact__clm_clmd_clmrsk_rska_properties_pv: 'MAXIMUS_TRAVEL'
  satfeed_mt_sat_common_contact__uwr_pol_ins_mbr_pa: 'MAXIMUS_TRAVEL'
  satfeed_mt_sat_common_contact__uwr_pol_ins_mbr_pa_address_prop_pv: 'MAXIMUS_TRAVEL'
  satfeed_mt_sat_common_contact__uwr_pol_ins_mbr_pp_sp_pv: 'MAXIMUS_TRAVEL'
  satfeed_mt_sat_common_contact__uwr_pol_prp_pa: 'MAXIMUS_TRAVEL'
  satfeed_mt_sat_common_contact__uwr_pol_prp_pa_address_prop_pv: 'MAXIMUS_TRAVEL'
  satfeed_mt_sat_common_contact__uwr_pol_prp_pp_sp_pv: 'MAXIMUS_TRAVEL'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ sat_multi_source(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model'],
                    src_record_source_map=metadata_dict['src_record_source_map'],
                    src_object_columns=['MOBILE_NUMBER'],
                    src_column_map={
                        'satfeed_mt_sat_common_contact__clm_clmd_clmap_pv': ['ALTERNATE_EMAIL_ADDRESS', 'ALTERNATE_MOBILE_NUMBER', 'CONTACT_POINT_USAGE', 'EMAIL_ADDRESS', 'FAX_NUMBER', 'LANDLINE_NUMBER', 'MOBILE_NUMBER', 'SOCIALMEDIAHANDLE', 'STD_CODE'],
                        'satfeed_mt_sat_common_contact__clm_clmd_clmrsk_rska_properties_pv': ['ALTERNATE_EMAIL_ADDRESS', 'ALTERNATE_MOBILE_NUMBER', 'CONTACT_POINT_USAGE', 'EMAIL_ADDRESS', 'FAX_NUMBER', 'LANDLINE_NUMBER', 'MOBILE_NUMBER', 'SOCIALMEDIAHANDLE', 'STD_CODE'],
                        'satfeed_mt_sat_common_contact__uwr_pol_ins_mbr_pa': ['ALTERNATE_EMAIL_ADDRESS', 'ALTERNATE_MOBILE_NUMBER', 'CONTACT_POINT_USAGE', 'EMAIL_ADDRESS', 'FAX_NUMBER', 'LANDLINE_NUMBER', 'MOBILE_NUMBER', 'SOCIALMEDIAHANDLE', 'STD_CODE'],
                        'satfeed_mt_sat_common_contact__uwr_pol_ins_mbr_pa_address_prop_pv': ['ALTERNATE_EMAIL_ADDRESS', 'ALTERNATE_MOBILE_NUMBER', 'CONTACT_POINT_USAGE', 'EMAIL_ADDRESS', 'FAX_NUMBER', 'LANDLINE_NUMBER', 'MOBILE_NUMBER', 'SOCIALMEDIAHANDLE', 'STD_CODE'],
                        'satfeed_mt_sat_common_contact__uwr_pol_ins_mbr_pp_sp_pv': ['ALTERNATE_EMAIL_ADDRESS', 'ALTERNATE_MOBILE_NUMBER', 'CONTACT_POINT_USAGE', 'EMAIL_ADDRESS', 'FAX_NUMBER', 'LANDLINE_NUMBER', 'MOBILE_NUMBER', 'SOCIALMEDIAHANDLE', 'STD_CODE'],
                        'satfeed_mt_sat_common_contact__uwr_pol_prp_pa': ['ALTERNATE_EMAIL_ADDRESS', 'ALTERNATE_MOBILE_NUMBER', 'CONTACT_POINT_USAGE', 'EMAIL_ADDRESS', 'FAX_NUMBER', 'LANDLINE_NUMBER', 'MOBILE_NUMBER', 'SOCIALMEDIAHANDLE', 'STD_CODE'],
                        'satfeed_mt_sat_common_contact__uwr_pol_prp_pa_address_prop_pv': ['ALTERNATE_EMAIL_ADDRESS', 'ALTERNATE_MOBILE_NUMBER', 'CONTACT_POINT_USAGE', 'EMAIL_ADDRESS', 'FAX_NUMBER', 'LANDLINE_NUMBER', 'MOBILE_NUMBER', 'SOCIALMEDIAHANDLE', 'STD_CODE'],
                        'satfeed_mt_sat_common_contact__uwr_pol_prp_pp_sp_pv': ['ALTERNATE_EMAIL_ADDRESS', 'ALTERNATE_MOBILE_NUMBER', 'CONTACT_POINT_USAGE', 'EMAIL_ADDRESS', 'FAX_NUMBER', 'LANDLINE_NUMBER', 'MOBILE_NUMBER', 'SOCIALMEDIAHANDLE', 'STD_CODE']
                    }) }}
