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
{{ config(materialized='view') }}

with merged as (

    -- branch 0: BJAZ_HAT_DISC_SUMMARY_LST | child-key literal(s): AUG_CLAIM_BILL_LINE.Bill Line Type=DISCOUNT
    select
        nullif(trim(disc_case_id),'') as CLAIM_BK,
        'DISCOUNT' as AUG_CLAIM_BILL_LINE__BILL_LINE_TYPE_CK,
        disc_particular_raw as AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_CK,
        cast(null as varchar) as AUG_CLAIM_BILL_LINE__BILL_HEAD_CODE_CK,
        cast(null as varchar) as AUG_CLAIM_BILL_LINE__BILL_HEAD_CODE,
        cast(null as varchar) as AUG_CLAIM_BILL_LINE__BILL_HEAD_LEVEL_1_NAME,
        cast(null as varchar) as AUG_CLAIM_BILL_LINE__BILL_HEAD_LEVEL_2_NAME,
        cast(null as varchar) as AUG_CLAIM_BILL_LINE__BILL_HEAD_LEVEL_3_NAME,
        disc_amount as AUG_CLAIM_BILL_LINE__LINE_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_AMOUNT_PER_UNIT,
        cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_CLAIMED_AMOUNT,
        disc_particular_raw as AUG_CLAIM_BILL_LINE__LINE_PARTICULAR,
        disc_particular_lead_term as AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_LEAD_TERM,
        disc_particular_profile_term as AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_PROFILE_TERM,
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
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__APPROVED_AMOUNT,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__AUTHORISED_AMOUNT,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILLED_AMOUNT,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_DATE,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_NUMBER,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_STATUS_TYPE,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_TYPE,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__DISALLOWANCE_REASON,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__DISALLOWED_AMOUNT,
        0 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hat_disc_summary_lst') }}
    where (nullif(trim(disc_case_id),'')) is not null

    union all

    -- branch 1: BJAZ_HAT_DISC_SUMMARY_LST
    select
        nullif(trim(disc_case_id),'') as CLAIM_BK,
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
        disc_bill_number as CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__APPROVED_AMOUNT,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__AUTHORISED_AMOUNT,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILLED_AMOUNT,
        disc_bill_date as CLAIM_PROVIDER_BILLING__BILL_DATE,
        disc_bill_number as CLAIM_PROVIDER_BILLING__BILL_NUMBER,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_STATUS_TYPE,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_TYPE,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__DISALLOWANCE_REASON,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__DISALLOWED_AMOUNT,
        0 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hat_disc_summary_lst') }}
    where (nullif(trim(disc_case_id),'')) is not null

    union all

    -- branch 2: BJAZ_HAT_NON_PAYABLE_LST | child-key literal(s): AUG_CLAIM_BILL_LINE.Bill Line Type=NON_PAYABLE
    select
        nullif(trim(non_pay_case_id),'') as CLAIM_BK,
        'NON_PAYABLE' as AUG_CLAIM_BILL_LINE__BILL_LINE_TYPE_CK,
        non_pay_particular as AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_CK,
        billhead as AUG_CLAIM_BILL_LINE__BILL_HEAD_CODE_CK,
        billhead as AUG_CLAIM_BILL_LINE__BILL_HEAD_CODE,
        non_pay_level_1 as AUG_CLAIM_BILL_LINE__BILL_HEAD_LEVEL_1_NAME,
        non_pay_level_2 as AUG_CLAIM_BILL_LINE__BILL_HEAD_LEVEL_2_NAME,
        non_pay_level_3 as AUG_CLAIM_BILL_LINE__BILL_HEAD_LEVEL_3_NAME,
        cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_AMOUNT,
        non_pay_amt_perunit as AUG_CLAIM_BILL_LINE__LINE_AMOUNT_PER_UNIT,
        non_pay_claimed_amount as AUG_CLAIM_BILL_LINE__LINE_CLAIMED_AMOUNT,
        non_pay_particular as AUG_CLAIM_BILL_LINE__LINE_PARTICULAR,
        cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_LEAD_TERM,
        cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_PROFILE_TERM,
        non_pay_is_payable as AUG_CLAIM_BILL_LINE__LINE_PAYABLE_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_SEQUENCE_NUMBER,
        non_pay_unit as AUG_CLAIM_BILL_LINE__LINE_UNIT_COUNT,
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
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__DISALLOWED_AMOUNT,
        1 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hat_non_payable_lst') }}
    where (nullif(trim(non_pay_case_id),'')) is not null

    union all

    -- branch 3: BJAZ_HAT_OCR_FINA_PERTICULARS | child-key literal(s): AUG_CLAIM_BILL_LINE.Bill Line Type=OCR_PARTICULAR
    select
        nullif(trim(case_id),'') as CLAIM_BK,
        'OCR_PARTICULAR' as AUG_CLAIM_BILL_LINE__BILL_LINE_TYPE_CK,
        particular as AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_CK,
        billhead as AUG_CLAIM_BILL_LINE__BILL_HEAD_CODE_CK,
        billhead as AUG_CLAIM_BILL_LINE__BILL_HEAD_CODE,
        cast(null as varchar) as AUG_CLAIM_BILL_LINE__BILL_HEAD_LEVEL_1_NAME,
        cast(null as varchar) as AUG_CLAIM_BILL_LINE__BILL_HEAD_LEVEL_2_NAME,
        level_3 as AUG_CLAIM_BILL_LINE__BILL_HEAD_LEVEL_3_NAME,
        amount as AUG_CLAIM_BILL_LINE__LINE_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_AMOUNT_PER_UNIT,
        cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_CLAIMED_AMOUNT,
        particular as AUG_CLAIM_BILL_LINE__LINE_PARTICULAR,
        cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_LEAD_TERM,
        cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_PROFILE_TERM,
        cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_PAYABLE_INDICATOR,
        sr_no as AUG_CLAIM_BILL_LINE__LINE_SEQUENCE_NUMBER,
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
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__APPROVED_AMOUNT,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__AUTHORISED_AMOUNT,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILLED_AMOUNT,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_DATE,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_NUMBER,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_STATUS_TYPE,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_TYPE,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__DISALLOWANCE_REASON,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__DISALLOWED_AMOUNT,
        2 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hat_ocr_fina_perticulars') }}
    where (nullif(trim(case_id),'')) is not null

    union all

    -- branch 4: BJAZ_HAT_OCR_FINA_PERTICULARS
    select
        nullif(trim(case_id),'') as CLAIM_BK,
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
        bill_number as CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__APPROVED_AMOUNT,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__AUTHORISED_AMOUNT,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILLED_AMOUNT,
        bill_date as CLAIM_PROVIDER_BILLING__BILL_DATE,
        bill_number as CLAIM_PROVIDER_BILLING__BILL_NUMBER,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_STATUS_TYPE,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_TYPE,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__DISALLOWANCE_REASON,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__DISALLOWED_AMOUNT,
        2 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hat_ocr_fina_perticulars') }}
    where (nullif(trim(case_id),'')) is not null

    union all

    -- branch 5: BJAZ_HAT_RETURN_SUMMARY_LST | child-key literal(s): AUG_CLAIM_BILL_LINE.Bill Line Type=RETURNED
    select
        nullif(trim(ret_case_id),'') as CLAIM_BK,
        'RETURNED' as AUG_CLAIM_BILL_LINE__BILL_LINE_TYPE_CK,
        ret_particular as AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_CK,
        cast(null as varchar) as AUG_CLAIM_BILL_LINE__BILL_HEAD_CODE_CK,
        cast(null as varchar) as AUG_CLAIM_BILL_LINE__BILL_HEAD_CODE,
        ret_level_1 as AUG_CLAIM_BILL_LINE__BILL_HEAD_LEVEL_1_NAME,
        ret_level_2 as AUG_CLAIM_BILL_LINE__BILL_HEAD_LEVEL_2_NAME,
        ret_level_3 as AUG_CLAIM_BILL_LINE__BILL_HEAD_LEVEL_3_NAME,
        cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_AMOUNT,
        ret_amount_per_unit as AUG_CLAIM_BILL_LINE__LINE_AMOUNT_PER_UNIT,
        ret_claimed_amount as AUG_CLAIM_BILL_LINE__LINE_CLAIMED_AMOUNT,
        ret_particular as AUG_CLAIM_BILL_LINE__LINE_PARTICULAR,
        cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_LEAD_TERM,
        cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_PROFILE_TERM,
        ret_is_payable as AUG_CLAIM_BILL_LINE__LINE_PAYABLE_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_BILL_LINE__LINE_SEQUENCE_NUMBER,
        ret_unit as AUG_CLAIM_BILL_LINE__LINE_UNIT_COUNT,
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
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__DISALLOWED_AMOUNT,
        3 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hat_return_summary_lst') }}
    where (nullif(trim(ret_case_id),'')) is not null

    union all

    -- branch 6: BJAZ_HM_GPA_BILL_DTLS
    select
        nullif(trim(claim_id),'') as CLAIM_BK,
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
        updated_by as AUG_CLAIM_PROVIDER_BILLING__BILL_ADJUDICATED_BY_USER,
        updated_on as AUG_CLAIM_PROVIDER_BILLING__BILL_ADJUDICATION_TIMESTAMP,
        cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__CLAIMED_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__CO_PAY_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__DISCOUNT_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__MOU_APPROVED_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__PATIENT_PAID_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__RELATED_BILL_REFERENCE,
        ptd_percentage as CLAIM_PA_DETAIL__DISABILITY_PERCENTAGE,
        bill_id as CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK,
        total_approved_amt as CLAIM_PROVIDER_BILLING__APPROVED_AMOUNT,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__AUTHORISED_AMOUNT,
        total_bill_amt as CLAIM_PROVIDER_BILLING__BILLED_AMOUNT,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_DATE,
        bill_id as CLAIM_PROVIDER_BILLING__BILL_NUMBER,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_STATUS_TYPE,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_TYPE,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__DISALLOWANCE_REASON,
        total_disallow_amt as CLAIM_PROVIDER_BILLING__DISALLOWED_AMOUNT,
        4 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_gpa_bill_dtls') }}
    where (nullif(trim(claim_id),'')) is not null

    union all

    -- branch 7: BJAZ_HM_BILL_CHARGE
    select
        claim_id as CLAIM_BK,
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
        bill_id as CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__APPROVED_AMOUNT,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__AUTHORISED_AMOUNT,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILLED_AMOUNT,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_DATE,
        bill_id as CLAIM_PROVIDER_BILLING__BILL_NUMBER,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_STATUS_TYPE,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_TYPE,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__DISALLOWANCE_REASON,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__DISALLOWED_AMOUNT,
        1005 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_bill_charge') }}
    where (claim_id) is not null

    union all

    -- branch 8: BJAZ_HM_BILL_DETAIL
    select
        claim_id as CLAIM_BK,
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
        claimed_amt as AUG_CLAIM_PROVIDER_BILLING__CLAIMED_AMOUNT,
        tot_copay_amt as AUG_CLAIM_PROVIDER_BILLING__CO_PAY_AMOUNT,
        discount as AUG_CLAIM_PROVIDER_BILLING__DISCOUNT_AMOUNT,
        tot_app_amtmou as AUG_CLAIM_PROVIDER_BILLING__MOU_APPROVED_AMOUNT,
        amt_frm_patient as AUG_CLAIM_PROVIDER_BILLING__PATIENT_PAID_AMOUNT,
        ref_bill_id as AUG_CLAIM_PROVIDER_BILLING__RELATED_BILL_REFERENCE,
        cast(null as varchar) as CLAIM_PA_DETAIL__DISABILITY_PERCENTAGE,
        bill_id as CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK,
        tot_approved_amt as CLAIM_PROVIDER_BILLING__APPROVED_AMOUNT,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__AUTHORISED_AMOUNT,
        tot_bill_amt as CLAIM_PROVIDER_BILLING__BILLED_AMOUNT,
        bill_date as CLAIM_PROVIDER_BILLING__BILL_DATE,
        coalesce(bill_id, hos_bill_no) as CLAIM_PROVIDER_BILLING__BILL_NUMBER,
        bill_status_type as CLAIM_PROVIDER_BILLING__BILL_STATUS_TYPE,
        bill_type as CLAIM_PROVIDER_BILLING__BILL_TYPE,
        dis_app_reason as CLAIM_PROVIDER_BILLING__DISALLOWANCE_REASON,
        tot_disallow_amt as CLAIM_PROVIDER_BILLING__DISALLOWED_AMOUNT,
        1006 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_bill_detail') }}
    where (claim_id) is not null

    union all

    -- branch 9: BJAZ_HM_BILL_DETAIL_OCR
    select
        claim_id as CLAIM_BK,
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
        claimed_amt as AUG_CLAIM_PROVIDER_BILLING__CLAIMED_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__CO_PAY_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__DISCOUNT_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__MOU_APPROVED_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__PATIENT_PAID_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__RELATED_BILL_REFERENCE,
        cast(null as varchar) as CLAIM_PA_DETAIL__DISABILITY_PERCENTAGE,
        bill_id as CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK,
        tot_approved_amt as CLAIM_PROVIDER_BILLING__APPROVED_AMOUNT,
        tot_app_amtmou as CLAIM_PROVIDER_BILLING__AUTHORISED_AMOUNT,
        tot_bill_amt as CLAIM_PROVIDER_BILLING__BILLED_AMOUNT,
        bill_date as CLAIM_PROVIDER_BILLING__BILL_DATE,
        coalesce(bill_id, hos_bill_no) as CLAIM_PROVIDER_BILLING__BILL_NUMBER,
        bill_status_type as CLAIM_PROVIDER_BILLING__BILL_STATUS_TYPE,
        bill_type as CLAIM_PROVIDER_BILLING__BILL_TYPE,
        dis_app_reason as CLAIM_PROVIDER_BILLING__DISALLOWANCE_REASON,
        tot_disallow_amt as CLAIM_PROVIDER_BILLING__DISALLOWED_AMOUNT,
        1007 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_bill_detail_ocr') }}
    where (claim_id) is not null

    union all

    -- branch 10: BJAZ_HM_HCM_EXTRACT
    select
        clid as CLAIM_BK,
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
        hospital_bill_no as CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__APPROVED_AMOUNT,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__AUTHORISED_AMOUNT,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILLED_AMOUNT,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_DATE,
        hospital_bill_no as CLAIM_PROVIDER_BILLING__BILL_NUMBER,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_STATUS_TYPE,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_TYPE,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__DISALLOWANCE_REASON,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__DISALLOWED_AMOUNT,
        1008 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
    where (clid) is not null

    union all

    -- branch 11: BJAZ_HM_PRO_ASSESSMENT
    select
        claim_id as CLAIM_BK,
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
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK,
        tot_approved_amt as CLAIM_PROVIDER_BILLING__APPROVED_AMOUNT,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__AUTHORISED_AMOUNT,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILLED_AMOUNT,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_DATE,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_NUMBER,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_STATUS_TYPE,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_TYPE,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__DISALLOWANCE_REASON,
        tot_disallow_amt as CLAIM_PROVIDER_BILLING__DISALLOWED_AMOUNT,
        1009 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_pro_assessment') }}
    where (claim_id) is not null

)

select
    CLAIM_BK,
    AUG_CLAIM_BILL_LINE__BILL_LINE_TYPE_CK,
    AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_CK,
    AUG_CLAIM_BILL_LINE__BILL_HEAD_CODE_CK,
    first_value(AUG_CLAIM_BILL_LINE__BILL_HEAD_CODE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_BILL_LINE__BILL_LINE_TYPE_CK, AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_CK, AUG_CLAIM_BILL_LINE__BILL_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_BILL_LINE__BILL_HEAD_CODE,
    first_value(AUG_CLAIM_BILL_LINE__BILL_HEAD_LEVEL_1_NAME) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_BILL_LINE__BILL_LINE_TYPE_CK, AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_CK, AUG_CLAIM_BILL_LINE__BILL_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_BILL_LINE__BILL_HEAD_LEVEL_1_NAME,
    first_value(AUG_CLAIM_BILL_LINE__BILL_HEAD_LEVEL_2_NAME) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_BILL_LINE__BILL_LINE_TYPE_CK, AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_CK, AUG_CLAIM_BILL_LINE__BILL_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_BILL_LINE__BILL_HEAD_LEVEL_2_NAME,
    first_value(AUG_CLAIM_BILL_LINE__BILL_HEAD_LEVEL_3_NAME) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_BILL_LINE__BILL_LINE_TYPE_CK, AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_CK, AUG_CLAIM_BILL_LINE__BILL_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_BILL_LINE__BILL_HEAD_LEVEL_3_NAME,
    first_value(AUG_CLAIM_BILL_LINE__LINE_AMOUNT) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_BILL_LINE__BILL_LINE_TYPE_CK, AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_CK, AUG_CLAIM_BILL_LINE__BILL_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_BILL_LINE__LINE_AMOUNT,
    first_value(AUG_CLAIM_BILL_LINE__LINE_AMOUNT_PER_UNIT) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_BILL_LINE__BILL_LINE_TYPE_CK, AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_CK, AUG_CLAIM_BILL_LINE__BILL_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_BILL_LINE__LINE_AMOUNT_PER_UNIT,
    first_value(AUG_CLAIM_BILL_LINE__LINE_CLAIMED_AMOUNT) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_BILL_LINE__BILL_LINE_TYPE_CK, AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_CK, AUG_CLAIM_BILL_LINE__BILL_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_BILL_LINE__LINE_CLAIMED_AMOUNT,
    first_value(AUG_CLAIM_BILL_LINE__LINE_PARTICULAR) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_BILL_LINE__BILL_LINE_TYPE_CK, AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_CK, AUG_CLAIM_BILL_LINE__BILL_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_BILL_LINE__LINE_PARTICULAR,
    first_value(AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_LEAD_TERM) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_BILL_LINE__BILL_LINE_TYPE_CK, AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_CK, AUG_CLAIM_BILL_LINE__BILL_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_LEAD_TERM,
    first_value(AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_PROFILE_TERM) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_BILL_LINE__BILL_LINE_TYPE_CK, AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_CK, AUG_CLAIM_BILL_LINE__BILL_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_PROFILE_TERM,
    first_value(AUG_CLAIM_BILL_LINE__LINE_PAYABLE_INDICATOR) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_BILL_LINE__BILL_LINE_TYPE_CK, AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_CK, AUG_CLAIM_BILL_LINE__BILL_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_BILL_LINE__LINE_PAYABLE_INDICATOR,
    first_value(AUG_CLAIM_BILL_LINE__LINE_SEQUENCE_NUMBER) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_BILL_LINE__BILL_LINE_TYPE_CK, AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_CK, AUG_CLAIM_BILL_LINE__BILL_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_BILL_LINE__LINE_SEQUENCE_NUMBER,
    first_value(AUG_CLAIM_BILL_LINE__LINE_UNIT_COUNT) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_BILL_LINE__BILL_LINE_TYPE_CK, AUG_CLAIM_BILL_LINE__LINE_PARTICULAR_CK, AUG_CLAIM_BILL_LINE__BILL_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_BILL_LINE__LINE_UNIT_COUNT,
    first_value(AUG_CLAIM_PROVIDER_BILLING__BILL_ADJUDICATED_BY_USER) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PROVIDER_BILLING__BILL_ADJUDICATED_BY_USER,
    first_value(AUG_CLAIM_PROVIDER_BILLING__BILL_ADJUDICATION_TIMESTAMP) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PROVIDER_BILLING__BILL_ADJUDICATION_TIMESTAMP,
    first_value(AUG_CLAIM_PROVIDER_BILLING__CLAIMED_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PROVIDER_BILLING__CLAIMED_AMOUNT,
    first_value(AUG_CLAIM_PROVIDER_BILLING__CO_PAY_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PROVIDER_BILLING__CO_PAY_AMOUNT,
    first_value(AUG_CLAIM_PROVIDER_BILLING__DISCOUNT_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PROVIDER_BILLING__DISCOUNT_AMOUNT,
    first_value(AUG_CLAIM_PROVIDER_BILLING__MOU_APPROVED_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PROVIDER_BILLING__MOU_APPROVED_AMOUNT,
    first_value(AUG_CLAIM_PROVIDER_BILLING__PATIENT_PAID_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PROVIDER_BILLING__PATIENT_PAID_AMOUNT,
    first_value(AUG_CLAIM_PROVIDER_BILLING__RELATED_BILL_REFERENCE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PROVIDER_BILLING__RELATED_BILL_REFERENCE,
    first_value(CLAIM_PA_DETAIL__DISABILITY_PERCENTAGE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_PA_DETAIL__DISABILITY_PERCENTAGE,
    CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK,
    first_value(CLAIM_PROVIDER_BILLING__APPROVED_AMOUNT) ignore nulls over (partition by CLAIM_BK, CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_PROVIDER_BILLING__APPROVED_AMOUNT,
    first_value(CLAIM_PROVIDER_BILLING__AUTHORISED_AMOUNT) ignore nulls over (partition by CLAIM_BK, CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_PROVIDER_BILLING__AUTHORISED_AMOUNT,
    first_value(CLAIM_PROVIDER_BILLING__BILLED_AMOUNT) ignore nulls over (partition by CLAIM_BK, CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_PROVIDER_BILLING__BILLED_AMOUNT,
    first_value(CLAIM_PROVIDER_BILLING__BILL_DATE) ignore nulls over (partition by CLAIM_BK, CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_PROVIDER_BILLING__BILL_DATE,
    first_value(CLAIM_PROVIDER_BILLING__BILL_NUMBER) ignore nulls over (partition by CLAIM_BK, CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_PROVIDER_BILLING__BILL_NUMBER,
    first_value(CLAIM_PROVIDER_BILLING__BILL_STATUS_TYPE) ignore nulls over (partition by CLAIM_BK, CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_PROVIDER_BILLING__BILL_STATUS_TYPE,
    first_value(CLAIM_PROVIDER_BILLING__BILL_TYPE) ignore nulls over (partition by CLAIM_BK, CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_PROVIDER_BILLING__BILL_TYPE,
    first_value(CLAIM_PROVIDER_BILLING__DISALLOWANCE_REASON) ignore nulls over (partition by CLAIM_BK, CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_PROVIDER_BILLING__DISALLOWANCE_REASON,
    first_value(CLAIM_PROVIDER_BILLING__DISALLOWED_AMOUNT) ignore nulls over (partition by CLAIM_BK, CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_PROVIDER_BILLING__DISALLOWED_AMOUNT
from merged
