{{ config(materialized='incremental') }}

-- STANDARD-MODEL ma_sat() for SAT_LNK_POLICY_PARTY_ROLE, per data_5a.js M2 (parent
-- LNK_POLICY_PARTY, childkey "Party Role Type" -- no Role Sequence source data, not
-- assumed). Additive, not a re-map: built off the SAME 23 branches already feeding
-- SAT_LNK_ROLE_NOMINEE_BENEFICIARY / SAT_LNK_ROLE_EMPLOYEE, at a different grain
-- (policy-scoped role, not the party's global role credential).
-- Payload gap, not an oversight: of this satellite's 9 other canonical attributes
-- (Role Sequence, Role Category, Intermediary Sub-Type, Attribution Percentage, Role
-- Effective/End Date, Primary Indicator, Role Status, Appointment Reference), none has
-- real source data across these branches -- left unbuilt, not fabricated.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_pprole_ba_hcp_prod_8428_gpg_loader__nominee'
  - 'stg2_pprole_ba_hcp_prod_8432_ecp_loader__nominee'
  - 'stg2_pprole_ba_hcp_prod_8433_fhc_loader__nominee'
  - 'stg2_pprole_ba_hcp_prod_8439_clh_loader__nominee'
  - 'stg2_pprole_bjaz_bandhan_medi_clam__nominee'
  - 'stg2_pprole_bjaz_ec_mem_dtls_extn__nominee'
  - 'stg2_pprole_bjaz_gp_hospital_cash__nominee'
  - 'stg2_pprole_bjaz_hcf_member_dtls__nominee'
  - 'stg2_pprole_bjaz_hc_part_extn__nominee'
  - 'stg2_pprole_bjaz_hdfc_sec_fhpp__nominee'
  - 'stg2_pprole_bjaz_hlt_ensure_mem_dtls__nominee'
  - 'stg2_pprole_bjaz_ihg_mem_dtls_extn__nominee'
  - 'stg2_pprole_bjaz_sh_mem_dtls_extn__nominee'
  - 'stg2_pprole_ba_hcp_prod_8428_gpg_loader__imd_relationship_manager'
  - 'stg2_pprole_ba_hcp_prod_8428_gpg_loader__insurer_relationship_manager'
  - 'stg2_pprole_ba_hcp_prod_8432_ecp_loader__imd_relationship_manager'
  - 'stg2_pprole_ba_hcp_prod_8432_ecp_loader__insurer_relationship_manager'
  - 'stg2_pprole_ba_hcp_prod_8433_fhc_loader__imd_relationship_manager'
  - 'stg2_pprole_ba_hcp_prod_8433_fhc_loader__insurer_relationship_manager'
  - 'stg2_pprole_ba_hcp_prod_8439_clh_loader__imd_relationship_manager'
  - 'stg2_pprole_ba_hcp_prod_8439_clh_loader__insurer_relationship_manager'
  - 'stg2_pprole_bjaz_gpg_pol_dtls__servicing_employee'
  - 'stg2_pprole_bjaz_gpg_pol_dtls__relationship_manager'
src_pk: 'POLICY_PARTY_HKEY'
src_cdk:
  - 'PARTY_ROLE_TYPE'
src_payload:
  - 'PARTY_ROLE_TYPE'
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
