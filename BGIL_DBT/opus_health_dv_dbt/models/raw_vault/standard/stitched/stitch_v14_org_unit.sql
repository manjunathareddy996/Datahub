{{ config(materialized='view') }}
-- CENTRAL VIEW v14_org_unit -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_BRANCH_MASTER (opus_health_v2)
--   BA_HCP_DT_PREMIUM (opus_health_legacy_v4)
--   BA_HCP_PROD_8433_FHC_LOADER (opus_health_legacy_v4)
--   BJAZ_HCF_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_IHG_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_SH_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_TPA_CLAIM_DETAILS_WS (opus_health_legacy_v4)
--   BJAZ_POLICY_BASES_EXTN (opus_health_delta3)
--   BJAZ_STARPKG_POL_DTLS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_ORG_UNIT_CONTACT
--   SAT_AUG_ORG_UNIT_DEFINITION
--   SAT_AUG_PARTY_EMPLOYMENT
--   SAT_ORG_UNIT_DEFINITION
--   SAT_ORG_UNIT_LICENCE
--   SAT_POLICY_BONUS_TRACKING
-- Links whose legs come from one source row on this view (rule 6):
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- Consumer view over parts: stitch_aug_org_unit_contact, stitch_aug_org_unit_definition, stitch_aug_party_employment, stitch_org_unit_definition, stitch_org_unit_licence, stitch_policy_bonus_tracking

select
    org_unit_bk as ORG_UNIT_BK,
    cast(null as varchar) as PARTY_BK,
    cast(null as varchar) as POLICY_BK,
    aug_org_unit_contact__email_address as AUG_ORG_UNIT_CONTACT__EMAIL_ADDRESS,
    aug_org_unit_contact__fax_number as AUG_ORG_UNIT_CONTACT__FAX_NUMBER,
    aug_org_unit_contact__landline_number as AUG_ORG_UNIT_CONTACT__LANDLINE_NUMBER,
    cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__ACCOUNTING_CATEGORY_CODE,
    cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__NEAREST_CONTROLLING_ORG_UNIT_REFERENCE,
    cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__ORG_UNIT_STATUS_REASON,
    cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__REGISTRATION_INDICATOR,
    cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__SOURCE_RECORD_DATE,
    cast(null as varchar) as AUG_PARTY_EMPLOYMENT__EMPLOYEE_NUMBER,
    cast(null as varchar) as AUG_PARTY_EMPLOYMENT__MONTHLY_SALARY_AMOUNT,
    cast(null as varchar) as ORG_UNIT_DEFINITION__BRANCH_TYPE,
    cast(null as varchar) as ORG_UNIT_DEFINITION__HEAD_REFERENCE,
    cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_CODE,
    cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_NAME,
    cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_STATUS,
    cast(null as varchar) as ORG_UNIT_DEFINITION__PARENT_ORG_UNIT_REFERENCE,
    cast(null as varchar) as ORG_UNIT_DEFINITION__ZONE_NAME,
    cast(null as varchar) as ORG_UNIT_LICENCE__GST_REGISTRATION_NUMBER,
    cast(null as varchar) as POLICY_BONUS_TRACKING__BONUS_AMOUNT,
    cast(null as varchar) as POLICY_BONUS_TRACKING__CUMULATIVE_BONUS_PERCENTAGE,
    cast(null as varchar) as POLICY_BONUS_TRACKING__NCB_PERCENTAGE
from {{ ref('stitch_aug_org_unit_contact') }}

union all

select
    org_unit_bk as ORG_UNIT_BK,
    cast(null as varchar) as PARTY_BK,
    cast(null as varchar) as POLICY_BK,
    cast(null as varchar) as AUG_ORG_UNIT_CONTACT__EMAIL_ADDRESS,
    cast(null as varchar) as AUG_ORG_UNIT_CONTACT__FAX_NUMBER,
    cast(null as varchar) as AUG_ORG_UNIT_CONTACT__LANDLINE_NUMBER,
    aug_org_unit_definition__accounting_category_code as AUG_ORG_UNIT_DEFINITION__ACCOUNTING_CATEGORY_CODE,
    aug_org_unit_definition__nearest_controlling_org_unit_reference as AUG_ORG_UNIT_DEFINITION__NEAREST_CONTROLLING_ORG_UNIT_REFERENCE,
    aug_org_unit_definition__org_unit_status_reason as AUG_ORG_UNIT_DEFINITION__ORG_UNIT_STATUS_REASON,
    aug_org_unit_definition__registration_indicator as AUG_ORG_UNIT_DEFINITION__REGISTRATION_INDICATOR,
    aug_org_unit_definition__source_record_date as AUG_ORG_UNIT_DEFINITION__SOURCE_RECORD_DATE,
    cast(null as varchar) as AUG_PARTY_EMPLOYMENT__EMPLOYEE_NUMBER,
    cast(null as varchar) as AUG_PARTY_EMPLOYMENT__MONTHLY_SALARY_AMOUNT,
    cast(null as varchar) as ORG_UNIT_DEFINITION__BRANCH_TYPE,
    cast(null as varchar) as ORG_UNIT_DEFINITION__HEAD_REFERENCE,
    cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_CODE,
    cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_NAME,
    cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_STATUS,
    cast(null as varchar) as ORG_UNIT_DEFINITION__PARENT_ORG_UNIT_REFERENCE,
    cast(null as varchar) as ORG_UNIT_DEFINITION__ZONE_NAME,
    cast(null as varchar) as ORG_UNIT_LICENCE__GST_REGISTRATION_NUMBER,
    cast(null as varchar) as POLICY_BONUS_TRACKING__BONUS_AMOUNT,
    cast(null as varchar) as POLICY_BONUS_TRACKING__CUMULATIVE_BONUS_PERCENTAGE,
    cast(null as varchar) as POLICY_BONUS_TRACKING__NCB_PERCENTAGE
from {{ ref('stitch_aug_org_unit_definition') }}

union all

select
    cast(null as varchar) as ORG_UNIT_BK,
    party_bk as PARTY_BK,
    cast(null as varchar) as POLICY_BK,
    cast(null as varchar) as AUG_ORG_UNIT_CONTACT__EMAIL_ADDRESS,
    cast(null as varchar) as AUG_ORG_UNIT_CONTACT__FAX_NUMBER,
    cast(null as varchar) as AUG_ORG_UNIT_CONTACT__LANDLINE_NUMBER,
    cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__ACCOUNTING_CATEGORY_CODE,
    cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__NEAREST_CONTROLLING_ORG_UNIT_REFERENCE,
    cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__ORG_UNIT_STATUS_REASON,
    cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__REGISTRATION_INDICATOR,
    cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__SOURCE_RECORD_DATE,
    aug_party_employment__employee_number as AUG_PARTY_EMPLOYMENT__EMPLOYEE_NUMBER,
    aug_party_employment__monthly_salary_amount as AUG_PARTY_EMPLOYMENT__MONTHLY_SALARY_AMOUNT,
    cast(null as varchar) as ORG_UNIT_DEFINITION__BRANCH_TYPE,
    cast(null as varchar) as ORG_UNIT_DEFINITION__HEAD_REFERENCE,
    cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_CODE,
    cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_NAME,
    cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_STATUS,
    cast(null as varchar) as ORG_UNIT_DEFINITION__PARENT_ORG_UNIT_REFERENCE,
    cast(null as varchar) as ORG_UNIT_DEFINITION__ZONE_NAME,
    cast(null as varchar) as ORG_UNIT_LICENCE__GST_REGISTRATION_NUMBER,
    cast(null as varchar) as POLICY_BONUS_TRACKING__BONUS_AMOUNT,
    cast(null as varchar) as POLICY_BONUS_TRACKING__CUMULATIVE_BONUS_PERCENTAGE,
    cast(null as varchar) as POLICY_BONUS_TRACKING__NCB_PERCENTAGE
from {{ ref('stitch_aug_party_employment') }}

union all

select
    org_unit_bk as ORG_UNIT_BK,
    cast(null as varchar) as PARTY_BK,
    cast(null as varchar) as POLICY_BK,
    cast(null as varchar) as AUG_ORG_UNIT_CONTACT__EMAIL_ADDRESS,
    cast(null as varchar) as AUG_ORG_UNIT_CONTACT__FAX_NUMBER,
    cast(null as varchar) as AUG_ORG_UNIT_CONTACT__LANDLINE_NUMBER,
    cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__ACCOUNTING_CATEGORY_CODE,
    cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__NEAREST_CONTROLLING_ORG_UNIT_REFERENCE,
    cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__ORG_UNIT_STATUS_REASON,
    cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__REGISTRATION_INDICATOR,
    cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__SOURCE_RECORD_DATE,
    cast(null as varchar) as AUG_PARTY_EMPLOYMENT__EMPLOYEE_NUMBER,
    cast(null as varchar) as AUG_PARTY_EMPLOYMENT__MONTHLY_SALARY_AMOUNT,
    org_unit_definition__branch_type as ORG_UNIT_DEFINITION__BRANCH_TYPE,
    org_unit_definition__head_reference as ORG_UNIT_DEFINITION__HEAD_REFERENCE,
    org_unit_definition__org_unit_code as ORG_UNIT_DEFINITION__ORG_UNIT_CODE,
    org_unit_definition__org_unit_name as ORG_UNIT_DEFINITION__ORG_UNIT_NAME,
    org_unit_definition__org_unit_status as ORG_UNIT_DEFINITION__ORG_UNIT_STATUS,
    org_unit_definition__parent_org_unit_reference as ORG_UNIT_DEFINITION__PARENT_ORG_UNIT_REFERENCE,
    org_unit_definition__zone_name as ORG_UNIT_DEFINITION__ZONE_NAME,
    cast(null as varchar) as ORG_UNIT_LICENCE__GST_REGISTRATION_NUMBER,
    cast(null as varchar) as POLICY_BONUS_TRACKING__BONUS_AMOUNT,
    cast(null as varchar) as POLICY_BONUS_TRACKING__CUMULATIVE_BONUS_PERCENTAGE,
    cast(null as varchar) as POLICY_BONUS_TRACKING__NCB_PERCENTAGE
from {{ ref('stitch_org_unit_definition') }}

union all

select
    org_unit_bk as ORG_UNIT_BK,
    cast(null as varchar) as PARTY_BK,
    cast(null as varchar) as POLICY_BK,
    cast(null as varchar) as AUG_ORG_UNIT_CONTACT__EMAIL_ADDRESS,
    cast(null as varchar) as AUG_ORG_UNIT_CONTACT__FAX_NUMBER,
    cast(null as varchar) as AUG_ORG_UNIT_CONTACT__LANDLINE_NUMBER,
    cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__ACCOUNTING_CATEGORY_CODE,
    cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__NEAREST_CONTROLLING_ORG_UNIT_REFERENCE,
    cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__ORG_UNIT_STATUS_REASON,
    cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__REGISTRATION_INDICATOR,
    cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__SOURCE_RECORD_DATE,
    cast(null as varchar) as AUG_PARTY_EMPLOYMENT__EMPLOYEE_NUMBER,
    cast(null as varchar) as AUG_PARTY_EMPLOYMENT__MONTHLY_SALARY_AMOUNT,
    cast(null as varchar) as ORG_UNIT_DEFINITION__BRANCH_TYPE,
    cast(null as varchar) as ORG_UNIT_DEFINITION__HEAD_REFERENCE,
    cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_CODE,
    cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_NAME,
    cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_STATUS,
    cast(null as varchar) as ORG_UNIT_DEFINITION__PARENT_ORG_UNIT_REFERENCE,
    cast(null as varchar) as ORG_UNIT_DEFINITION__ZONE_NAME,
    org_unit_licence__gst_registration_number as ORG_UNIT_LICENCE__GST_REGISTRATION_NUMBER,
    cast(null as varchar) as POLICY_BONUS_TRACKING__BONUS_AMOUNT,
    cast(null as varchar) as POLICY_BONUS_TRACKING__CUMULATIVE_BONUS_PERCENTAGE,
    cast(null as varchar) as POLICY_BONUS_TRACKING__NCB_PERCENTAGE
from {{ ref('stitch_org_unit_licence') }}

union all

select
    cast(null as varchar) as ORG_UNIT_BK,
    cast(null as varchar) as PARTY_BK,
    policy_bk as POLICY_BK,
    cast(null as varchar) as AUG_ORG_UNIT_CONTACT__EMAIL_ADDRESS,
    cast(null as varchar) as AUG_ORG_UNIT_CONTACT__FAX_NUMBER,
    cast(null as varchar) as AUG_ORG_UNIT_CONTACT__LANDLINE_NUMBER,
    cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__ACCOUNTING_CATEGORY_CODE,
    cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__NEAREST_CONTROLLING_ORG_UNIT_REFERENCE,
    cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__ORG_UNIT_STATUS_REASON,
    cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__REGISTRATION_INDICATOR,
    cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__SOURCE_RECORD_DATE,
    cast(null as varchar) as AUG_PARTY_EMPLOYMENT__EMPLOYEE_NUMBER,
    cast(null as varchar) as AUG_PARTY_EMPLOYMENT__MONTHLY_SALARY_AMOUNT,
    cast(null as varchar) as ORG_UNIT_DEFINITION__BRANCH_TYPE,
    cast(null as varchar) as ORG_UNIT_DEFINITION__HEAD_REFERENCE,
    cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_CODE,
    cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_NAME,
    cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_STATUS,
    cast(null as varchar) as ORG_UNIT_DEFINITION__PARENT_ORG_UNIT_REFERENCE,
    cast(null as varchar) as ORG_UNIT_DEFINITION__ZONE_NAME,
    cast(null as varchar) as ORG_UNIT_LICENCE__GST_REGISTRATION_NUMBER,
    policy_bonus_tracking__bonus_amount as POLICY_BONUS_TRACKING__BONUS_AMOUNT,
    policy_bonus_tracking__cumulative_bonus_percentage as POLICY_BONUS_TRACKING__CUMULATIVE_BONUS_PERCENTAGE,
    policy_bonus_tracking__ncb_percentage as POLICY_BONUS_TRACKING__NCB_PERCENTAGE
from {{ ref('stitch_policy_bonus_tracking') }}
