{{ config(materialized='incremental') }}

-- AUGMENTED (unconfirmed) sat() for SAT_AUG_PARTY (HUB_PARTY grain).
-- 10 contributing table(s), union (no attribute merge attempted --
-- these columns were never analysed for cross-table overlap, unlike standard-model
-- satellites). NOT part of the canonical data_v4.js model. Needs mapper review before
-- being treated as equivalent to a standard-model satellite -- see docs.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_aug_ba_hcp_dt_premium__party'
  - 'stg2_aug_ba_hcp_prod_8428_gpg_loader__party'
  - 'stg2_aug_ba_hcp_prod_8432_ecp_loader__party'
  - 'stg2_aug_ba_hcp_prod_8433_fhc_loader__party'
  - 'stg2_aug_bjaz_hm_hospital_master__party'
  - 'stg2_aug_bjaz_hm_hospital_master_extn__party'
  - 'stg2_aug_bjaz_hm_hosp_master_extn1__party'
  - 'stg2_aug_bjaz_hm_inward_dtls__party'
  - 'stg2_aug_bjaz_hm_member_dtls__party'
  - 'stg2_aug_bjaz_remedinet_claim_details__party'
src_pk: 'PARTY_HK'
src_payload:
  - 'BEDOCCUPRATE'
  - 'BENNAME'
  - 'CEO'
  - 'CONTACT_PERSON'
  - 'DTOPRATIO'
  - 'EMP_NO'
  - 'HC_NO_OF_DAYS'
  - 'HOSPITAL_NO'
  - 'HOSP_PORTAL_FLAG'
  - 'HOSP_PRIORITY_FLAG'
  - 'HOSSTATUSREMARK'
  - 'HOS_REMARK'
  - 'IMPS_ACTIVE_DATE'
  - 'IMPS_END_DATE'
  - 'IMPS_PAYMENT_LMT'
  - 'IMPS_TARIF_FRM'
  - 'IMPS_TARIF_TO'
  - 'INS_DEPT_CONTACT1'
  - 'INS_DEPT_CONTACT2'
  - 'MEDICALDIRECT'
  - 'MEDSUPERNAME'
  - 'MKTHEAD'
  - 'MLAC_EMI_PC_LOAN_PERIOD'
  - 'MLAC_HOSP_CASH_NO_OF_DAYS'
  - 'NEFT_STATUS'
  - 'NETWORK_TYPE'
  - 'PARTNER_ID'
  - 'PAYER_PROVIDER_CODE'
  - 'PD_BANK_REF_NO2_BANK_CUST_ID'
  - 'PRIORITY_FLAG'
  - 'PRIORITY_FLG'
  - 'REACTIDATE'
  - 'RE_EMPANEL_DATE'
  - 'SPECIAL_REMARKS'
  - 'TPANAME'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
