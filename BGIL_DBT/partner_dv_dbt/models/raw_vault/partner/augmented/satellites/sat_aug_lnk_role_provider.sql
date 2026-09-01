{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key=['PARTY_HKEY', 'HASHDIFF', 'RECORD_SOURCE']
    )
}}

-- PARTNER AUGMENTED (unconfirmed) sat_multi_source() for SAT_AUG_LNK_ROLE_PROVIDER
-- (HUB_PARTY grain, role-special: 'provider'). NOT part of the canonical data_5a.js
-- model as such -- SAT_LNK_ROLE_PROVIDER itself IS canonical (parent LNK_PARTY_ROLE),
-- but these are extra attributes the mapper's Augmentation sheet flagged, built here
-- using the same role-special HUB_PARTY pattern as the standard-model satellite.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_aug_rolesat_bjaz_clm_supp_extn__lnk_role_provider'
  - 'stg2_aug_rolesat_bjaz_hm_hospital_master__lnk_role_provider'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'BAGIC_LOCATION'
  - 'CLAIM_NEAR_ME_FLAG'
  - 'CLASS'
  - 'COMP_TYPE'
  - 'CONTACT_PERSON_DESIGNATION'
  - 'CONTACT_PERSON_NAME'
  - 'CON_EXPERTISE'
  - 'COVERED_AREA'
  - 'DEALER_CODE'
  - 'DEDUCTIBLE_EXEMPT'
  - 'DIAGNO_YN'
  - 'EMPANEL_DATE'
  - 'EW_WHITE_GOODS_FLG'
  - 'EXP_LOB_ENGINEERING_FLG'
  - 'EXP_LOB_FIRE_FLG'
  - 'EXP_LOB_LOSS_PROFIT_FLG'
  - 'EXP_LOB_MARINE_HULL_FLG'
  - 'EXP_LOB_MARIN_CARGO_FLG'
  - 'EXP_LOB_MISCELL_FLG'
  - 'EXP_LOB_MOTOR_FLG'
  - 'EXP_LOB_WORKMAN_COMP_FLG'
  - 'GRADE'
  - 'HOSP_SPEC_TYPE'
  - 'INVOICE_PATTERN'
  - 'IRN_FLAG'
  - 'JW_FLAG'
  - 'JW_ID'
  - 'LVS_FLAG'
  - 'MOU_STATUS'
  - 'NETWORK_TYPE'
  - 'NO_TOWING_VEHICLE'
  - 'ON_DUTY_FLAG'
  - 'OPERATION_PLACE'
  - 'ORIGIN_COMP'
  - 'ORIGIN_CONT'
  - 'OTHER_BAGIC_BUSINESS'
  - 'OWNRSHIP_DEPT'
  - 'PRIORITY'
  - 'PRIORITY_FLG'
  - 'SPEC_REPAIRER'
  - 'SUPP_OWNERSHIP'
  - 'SUPP_SCOPE'
  - 'TOWING_VEHICLE'
  - 'WORKSHOP_CATEGORY'
  - 'WORKSHOP_CLASS'
  - 'WORKSHOP_NAME'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ sat_multi_source(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model'],
                    src_column_map={
                        'stg2_aug_rolesat_bjaz_clm_supp_extn__lnk_role_provider': ['BAGIC_LOCATION', 'CLAIM_NEAR_ME_FLAG', 'CLASS', 'COMP_TYPE', 'CONTACT_PERSON_NAME', 'CON_EXPERTISE', 'COVERED_AREA', 'DEALER_CODE', 'DEDUCTIBLE_EXEMPT', 'EW_WHITE_GOODS_FLG', 'EXP_LOB_ENGINEERING_FLG', 'EXP_LOB_FIRE_FLG', 'EXP_LOB_LOSS_PROFIT_FLG', 'EXP_LOB_MARINE_HULL_FLG', 'EXP_LOB_MARIN_CARGO_FLG', 'EXP_LOB_MISCELL_FLG', 'EXP_LOB_MOTOR_FLG', 'EXP_LOB_WORKMAN_COMP_FLG', 'GRADE', 'INVOICE_PATTERN', 'IRN_FLAG', 'JW_FLAG', 'JW_ID', 'LVS_FLAG', 'MOU_STATUS', 'NO_TOWING_VEHICLE', 'ON_DUTY_FLAG', 'OPERATION_PLACE', 'ORIGIN_COMP', 'ORIGIN_CONT', 'OTHER_BAGIC_BUSINESS', 'OWNRSHIP_DEPT', 'PRIORITY', 'SPEC_REPAIRER', 'SUPP_OWNERSHIP', 'SUPP_SCOPE', 'TOWING_VEHICLE', 'WORKSHOP_CATEGORY', 'WORKSHOP_CLASS', 'WORKSHOP_NAME'],
                        'stg2_aug_rolesat_bjaz_hm_hospital_master__lnk_role_provider': ['CONTACT_PERSON_DESIGNATION', 'CONTACT_PERSON_NAME', 'DIAGNO_YN', 'EMPANEL_DATE', 'HOSP_SPEC_TYPE', 'NETWORK_TYPE', 'PRIORITY_FLG']
                    }) }}
