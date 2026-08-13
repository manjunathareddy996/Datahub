{{ config(materialized='view') }}

-- PARTNER AUGMENTED (unconfirmed) per-table stage() for SAT_AUG_LNK_ROLE_PROVIDER
-- (HUB_PARTY grain, role-special: 'provider'), table 'BJAZ_CLM_SUPP_EXTN'.
-- Reuses the exact PARTY_HKEY formula (partner_id) from the matching standard-model
-- stg2_rolesat_*__lnk_role_provider.sql. Same table also plays 'surveyor' -- see stg2_rolesat_bjaz_clm_supp_extn__lnk_role_surveyor.sql.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_clm_supp_extn'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'GRADE'
      - 'CLASS'
      - 'DEALER_CODE'
      - 'MOU_STATUS'
      - 'TOWING_VEHICLE'
      - 'NO_TOWING_VEHICLE'
      - 'COVERED_AREA'
      - 'WORKSHOP_CATEGORY'
      - 'CONTACT_PERSON_NAME'
      - 'SPEC_REPAIRER'
      - 'ORIGIN_COMP'
      - 'COMP_TYPE'
      - 'ORIGIN_CONT'
      - 'CON_EXPERTISE'
      - 'OPERATION_PLACE'
      - 'OTHER_BAGIC_BUSINESS'
      - 'BAGIC_LOCATION'
      - 'WORKSHOP_NAME'
      - 'WORKSHOP_CLASS'
      - 'SUPP_OWNERSHIP'
      - 'SUPP_SCOPE'
      - 'PRIORITY'
      - 'EW_WHITE_GOODS_FLG'
      - 'EXP_LOB_FIRE_FLG'
      - 'EXP_LOB_MARIN_CARGO_FLG'
      - 'EXP_LOB_MOTOR_FLG'
      - 'EXP_LOB_MISCELL_FLG'
      - 'EXP_LOB_MARINE_HULL_FLG'
      - 'EXP_LOB_ENGINEERING_FLG'
      - 'EXP_LOB_LOSS_PROFIT_FLG'
      - 'EXP_LOB_WORKMAN_COMP_FLG'
      - 'LVS_FLAG'
      - 'IRN_FLAG'
      - 'OWNRSHIP_DEPT'
      - 'INVOICE_PATTERN'
      - 'DEDUCTIBLE_EXEMPT'
      - 'ON_DUTY_FLAG'
      - 'CLAIM_NEAR_ME_FLAG'
      - 'JW_ID'
      - 'JW_FLAG'
derived_columns:
  PARENT_BK: 'partner_id'
  PARENT_NK: "'HUB_PARTY|' || (partner_id)"
  GRADE: 'grade'
  CLASS: 'class'
  DEALER_CODE: 'dealer_code'
  MOU_STATUS: 'mou_status'
  TOWING_VEHICLE: 'towing_vehicle'
  NO_TOWING_VEHICLE: 'no_towing_vehicle'
  COVERED_AREA: 'covered_area'
  WORKSHOP_CATEGORY: 'workshop_category'
  CONTACT_PERSON_NAME: 'contact_person_name'
  SPEC_REPAIRER: 'spec_repairer'
  ORIGIN_COMP: 'origin_comp'
  COMP_TYPE: 'comp_type'
  ORIGIN_CONT: 'origin_cont'
  CON_EXPERTISE: 'con_expertise'
  OPERATION_PLACE: 'operation_place'
  OTHER_BAGIC_BUSINESS: 'other_bagic_business'
  BAGIC_LOCATION: 'bagic_location'
  WORKSHOP_NAME: 'workshop_name'
  WORKSHOP_CLASS: 'workshop_class'
  SUPP_OWNERSHIP: 'supp_ownership'
  SUPP_SCOPE: 'supp_scope'
  PRIORITY: 'priority'
  EW_WHITE_GOODS_FLG: 'ew_white_goods_flg'
  EXP_LOB_FIRE_FLG: 'exp_lob_fire_flg'
  EXP_LOB_MARIN_CARGO_FLG: 'exp_lob_marin_cargo_flg'
  EXP_LOB_MOTOR_FLG: 'exp_lob_motor_flg'
  EXP_LOB_MISCELL_FLG: 'exp_lob_miscell_flg'
  EXP_LOB_MARINE_HULL_FLG: 'exp_lob_marine_hull_flg'
  EXP_LOB_ENGINEERING_FLG: 'exp_lob_engineering_flg'
  EXP_LOB_LOSS_PROFIT_FLG: 'exp_lob_loss_profit_flg'
  EXP_LOB_WORKMAN_COMP_FLG: 'exp_lob_workman_comp_flg'
  LVS_FLAG: 'lvs_flag'
  IRN_FLAG: 'irn_flag'
  OWNRSHIP_DEPT: 'ownrship_dept'
  INVOICE_PATTERN: 'invoice_pattern'
  DEDUCTIBLE_EXEMPT: 'deductible_exempt'
  ON_DUTY_FLAG: 'on_duty_flag'
  CLAIM_NEAR_ME_FLAG: 'claim_near_me_flag'
  JW_ID: 'jw_id'
  JW_FLAG: 'jw_flag'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_CLM_SUPP_EXTN'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
