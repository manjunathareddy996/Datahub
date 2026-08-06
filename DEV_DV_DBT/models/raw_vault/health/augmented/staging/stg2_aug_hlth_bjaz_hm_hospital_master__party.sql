{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_PARTY, table 'BJAZ_HM_HOSPITAL_MASTER'.
-- 12 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BJAZ_HM_HOSPITAL_MASTER carries a verified HUB_PARTY key
-- (HOSID), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_hospital_master'
hashed_columns:
  PARTY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PARTNER_ID'
      - 'HOSPITAL_NO'
      - 'CONTACT_PERSON'
      - 'NETWORK_TYPE'
      - 'BENNAME'
      - 'HOS_REMARK'
      - 'PRIORITY_FLG'
      - 'IMPS_ACTIVE_DATE'
      - 'IMPS_END_DATE'
      - 'IMPS_TARIF_FRM'
      - 'IMPS_TARIF_TO'
      - 'IMPS_PAYMENT_LMT'
derived_columns:
  PARENT_BK: 'hosid'
  PARENT_NK: "'HUB_PARTY|' || (hosid)"
  PARTNER_ID: 'partner_id'
  HOSPITAL_NO: 'hospital_no'
  CONTACT_PERSON: 'contact_person'
  NETWORK_TYPE: 'network_type'
  BENNAME: 'benname'
  HOS_REMARK: 'hos_remark'
  PRIORITY_FLG: 'priority_flg'
  IMPS_ACTIVE_DATE: 'imps_active_date'
  IMPS_END_DATE: 'imps_end_date'
  IMPS_TARIF_FRM: 'imps_tarif_frm'
  IMPS_TARIF_TO: 'imps_tarif_to'
  IMPS_PAYMENT_LMT: 'imps_payment_lmt'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_HOSPITAL_MASTER'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
