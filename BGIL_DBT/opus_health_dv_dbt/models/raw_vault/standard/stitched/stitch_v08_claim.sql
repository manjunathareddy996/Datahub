{{ config(materialized='view') }}
-- CENTRAL VIEW v08_claim -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_HAT_DISC_SUMMARY_LST (opus_health_v2)
--   BJAZ_HAT_NON_PAYABLE_LST (opus_health_v2)
--   BJAZ_HAT_OCR_FINA_PERTICULARS (opus_health_v2)
--   BJAZ_HAT_RETURN_SUMMARY_LST (opus_health_v2)
--   BJAZ_HM_GPA_BILL_DTLS (opus_health_v2)
--   BJAZ_HM_BILL_CHARGE (opus_health_legacy_v4)
--   BJAZ_HM_BILL_DETAIL (opus_health_legacy_v4)
--   BJAZ_HM_BILL_DETAIL_OCR (opus_health_legacy_v4)
--   BJAZ_HM_HCM_EXTRACT (opus_health_legacy_v4)
--   BJAZ_HM_PRO_ASSESSMENT (opus_health_legacy_v4)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_CLAIM_BILL_LINE
--   SAT_AUG_CLAIM_PROVIDER_BILLING
--   SAT_CLAIM_PA_DETAIL
--   SAT_CLAIM_PROVIDER_BILLING
-- Links whose legs come from one source row on this view (rule 6):
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- Consumer view over parts: stitch_aug_claim_bill_line, stitch_aug_claim_provider_billing, stitch_claim_pa_detail, stitch_claim_provider_billing

select
    claim_bk as CLAIM_BK,
    aug_claim_bill_line__bill_line_type_ck as AUG_CLAIM_BILL_LINE__BILL_LINE_TYPE_CK,
    aug_claim_bill_line__line_particular_ck as AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_CK,
    aug_claim_bill_line__bill_head_code_ck as AUG_CLAIM_BILL_LINE__BILL_HEAD_CODE_CK,
    aug_claim_bill_line__bill_head_code as AUG_CLAIM_BILL_LINE__BILL_HEAD_CODE,
    aug_claim_bill_line__bill_head_level_1_name as AUG_CLAIM_BILL_LINE__BILL_HEAD_LEVEL_1_NAME,
    aug_claim_bill_line__bill_head_level_2_name as AUG_CLAIM_BILL_LINE__BILL_HEAD_LEVEL_2_NAME,
    aug_claim_bill_line__bill_head_level_3_name as AUG_CLAIM_BILL_LINE__BILL_HEAD_LEVEL_3_NAME,
    aug_claim_bill_line__line_amount as AUG_CLAIM_BILL_LINE__LINE_AMOUNT,
    aug_claim_bill_line__line_amount_per_unit as AUG_CLAIM_BILL_LINE__LINE_AMOUNT_PER_UNIT,
    aug_claim_bill_line__line_claimed_amount as AUG_CLAIM_BILL_LINE__LINE_CLAIMED_AMOUNT,
    aug_claim_bill_line__line_particular as AUG_CLAIM_BILL_LINE__LINE_PARTICULAR,
    aug_claim_bill_line__line_particular_lead_term as AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_LEAD_TERM,
    aug_claim_bill_line__line_particular_profile_term as AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_PROFILE_TERM,
    aug_claim_bill_line__line_payable_indicator as AUG_CLAIM_BILL_LINE__LINE_PAYABLE_INDICATOR,
    aug_claim_bill_line__line_sequence_number as AUG_CLAIM_BILL_LINE__LINE_SEQUENCE_NUMBER,
    aug_claim_bill_line__line_unit_count as AUG_CLAIM_BILL_LINE__LINE_UNIT_COUNT,
    cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__BILL_ADJUDICATED_BY_USER,
    cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__BILL_ADJUDICATION_TIMESTAMP,
    cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__CLAIMED_AMOUNT,
    cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__CO_PAY_AMOUNT,
    cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__DISCOUNT_AMOUNT,
    cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__MOU_APPROVED_AMOUNT,
    cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__PATIENT_PAID_AMOUNT,
    cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__RELATED_BILL_REFERENCE,
    cast(null as varchar) as CLAIM_PA_DETAIL__DISABILITY_PERCENTAGE,
    cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK,
    cast(null as varchar) as CLAIM_PROVIDER_BILLING__APPROVED_AMOUNT,
    cast(null as varchar) as CLAIM_PROVIDER_BILLING__AUTHORISED_AMOUNT,
    cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILLED_AMOUNT,
    cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_DATE,
    cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_NUMBER,
    cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_STATUS_TYPE,
    cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_TYPE,
    cast(null as varchar) as CLAIM_PROVIDER_BILLING__DISALLOWANCE_REASON,
    cast(null as varchar) as CLAIM_PROVIDER_BILLING__DISALLOWED_AMOUNT
from {{ ref('stitch_aug_claim_bill_line') }}

union all

select
    claim_bk as CLAIM_BK,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__BILL_LINE_TYPE_CK,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_CK,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__BILL_HEAD_CODE_CK,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__BILL_HEAD_CODE,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__BILL_HEAD_LEVEL_1_NAME,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__BILL_HEAD_LEVEL_2_NAME,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__BILL_HEAD_LEVEL_3_NAME,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_AMOUNT,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_AMOUNT_PER_UNIT,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_CLAIMED_AMOUNT,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_PARTICULAR,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_LEAD_TERM,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_PROFILE_TERM,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_PAYABLE_INDICATOR,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_SEQUENCE_NUMBER,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_UNIT_COUNT,
    aug_claim_provider_billing__bill_adjudicated_by_user as AUG_CLAIM_PROVIDER_BILLING__BILL_ADJUDICATED_BY_USER,
    aug_claim_provider_billing__bill_adjudication_timestamp as AUG_CLAIM_PROVIDER_BILLING__BILL_ADJUDICATION_TIMESTAMP,
    aug_claim_provider_billing__claimed_amount as AUG_CLAIM_PROVIDER_BILLING__CLAIMED_AMOUNT,
    aug_claim_provider_billing__co_pay_amount as AUG_CLAIM_PROVIDER_BILLING__CO_PAY_AMOUNT,
    aug_claim_provider_billing__discount_amount as AUG_CLAIM_PROVIDER_BILLING__DISCOUNT_AMOUNT,
    aug_claim_provider_billing__mou_approved_amount as AUG_CLAIM_PROVIDER_BILLING__MOU_APPROVED_AMOUNT,
    aug_claim_provider_billing__patient_paid_amount as AUG_CLAIM_PROVIDER_BILLING__PATIENT_PAID_AMOUNT,
    aug_claim_provider_billing__related_bill_reference as AUG_CLAIM_PROVIDER_BILLING__RELATED_BILL_REFERENCE,
    cast(null as varchar) as CLAIM_PA_DETAIL__DISABILITY_PERCENTAGE,
    cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK,
    cast(null as varchar) as CLAIM_PROVIDER_BILLING__APPROVED_AMOUNT,
    cast(null as varchar) as CLAIM_PROVIDER_BILLING__AUTHORISED_AMOUNT,
    cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILLED_AMOUNT,
    cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_DATE,
    cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_NUMBER,
    cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_STATUS_TYPE,
    cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_TYPE,
    cast(null as varchar) as CLAIM_PROVIDER_BILLING__DISALLOWANCE_REASON,
    cast(null as varchar) as CLAIM_PROVIDER_BILLING__DISALLOWED_AMOUNT
from {{ ref('stitch_aug_claim_provider_billing') }}

union all

select
    claim_bk as CLAIM_BK,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__BILL_LINE_TYPE_CK,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_CK,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__BILL_HEAD_CODE_CK,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__BILL_HEAD_CODE,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__BILL_HEAD_LEVEL_1_NAME,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__BILL_HEAD_LEVEL_2_NAME,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__BILL_HEAD_LEVEL_3_NAME,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_AMOUNT,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_AMOUNT_PER_UNIT,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_CLAIMED_AMOUNT,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_PARTICULAR,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_LEAD_TERM,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_PROFILE_TERM,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_PAYABLE_INDICATOR,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_SEQUENCE_NUMBER,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_UNIT_COUNT,
    cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__BILL_ADJUDICATED_BY_USER,
    cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__BILL_ADJUDICATION_TIMESTAMP,
    cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__CLAIMED_AMOUNT,
    cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__CO_PAY_AMOUNT,
    cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__DISCOUNT_AMOUNT,
    cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__MOU_APPROVED_AMOUNT,
    cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__PATIENT_PAID_AMOUNT,
    cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__RELATED_BILL_REFERENCE,
    claim_pa_detail__disability_percentage as CLAIM_PA_DETAIL__DISABILITY_PERCENTAGE,
    cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK,
    cast(null as varchar) as CLAIM_PROVIDER_BILLING__APPROVED_AMOUNT,
    cast(null as varchar) as CLAIM_PROVIDER_BILLING__AUTHORISED_AMOUNT,
    cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILLED_AMOUNT,
    cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_DATE,
    cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_NUMBER,
    cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_STATUS_TYPE,
    cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_TYPE,
    cast(null as varchar) as CLAIM_PROVIDER_BILLING__DISALLOWANCE_REASON,
    cast(null as varchar) as CLAIM_PROVIDER_BILLING__DISALLOWED_AMOUNT
from {{ ref('stitch_claim_pa_detail') }}

union all

select
    claim_bk as CLAIM_BK,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__BILL_LINE_TYPE_CK,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_CK,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__BILL_HEAD_CODE_CK,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__BILL_HEAD_CODE,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__BILL_HEAD_LEVEL_1_NAME,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__BILL_HEAD_LEVEL_2_NAME,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__BILL_HEAD_LEVEL_3_NAME,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_AMOUNT,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_AMOUNT_PER_UNIT,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_CLAIMED_AMOUNT,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_PARTICULAR,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_LEAD_TERM,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_PROFILE_TERM,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_PAYABLE_INDICATOR,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_SEQUENCE_NUMBER,
    cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_UNIT_COUNT,
    cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__BILL_ADJUDICATED_BY_USER,
    cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__BILL_ADJUDICATION_TIMESTAMP,
    cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__CLAIMED_AMOUNT,
    cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__CO_PAY_AMOUNT,
    cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__DISCOUNT_AMOUNT,
    cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__MOU_APPROVED_AMOUNT,
    cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__PATIENT_PAID_AMOUNT,
    cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__RELATED_BILL_REFERENCE,
    cast(null as varchar) as CLAIM_PA_DETAIL__DISABILITY_PERCENTAGE,
    claim_provider_billing__bill_number_ck as CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK,
    claim_provider_billing__approved_amount as CLAIM_PROVIDER_BILLING__APPROVED_AMOUNT,
    claim_provider_billing__authorised_amount as CLAIM_PROVIDER_BILLING__AUTHORISED_AMOUNT,
    claim_provider_billing__billed_amount as CLAIM_PROVIDER_BILLING__BILLED_AMOUNT,
    claim_provider_billing__bill_date as CLAIM_PROVIDER_BILLING__BILL_DATE,
    claim_provider_billing__bill_number as CLAIM_PROVIDER_BILLING__BILL_NUMBER,
    claim_provider_billing__bill_status_type as CLAIM_PROVIDER_BILLING__BILL_STATUS_TYPE,
    claim_provider_billing__bill_type as CLAIM_PROVIDER_BILLING__BILL_TYPE,
    claim_provider_billing__disallowance_reason as CLAIM_PROVIDER_BILLING__DISALLOWANCE_REASON,
    claim_provider_billing__disallowed_amount as CLAIM_PROVIDER_BILLING__DISALLOWED_AMOUNT
from {{ ref('stitch_claim_provider_billing') }}
