-- CENTRAL VIEW v22_quote -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   BA_PART_QUOTE_MOT_PREM
--   BA_QUOTE_MOT_COVERS
--   BA_QUOTE_MOT_DTLS
--   BA_QUOTE_MOT_PREM
--   BGIL_MOTOR_WS_DETARIFF_EQM
--   BGIL_MOTWS_OTHER_DTLS_EQM
--   BJAZ_MOTOR_WS_DETARIFF
--   BJAZ_MOTOR_WS_EXTRA_COVERS
--   BJAZ_MOTOR_WS_PREMIUM_SUMMARY
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_MOTOR_AUG_QUOTE_COVERAGE_LINE
--   SAT_MOTOR_AUG_QUOTE_PREMIUM_HEAD
--   SAT_MOTOR_AUG_QUOTE_VEHICLE_SPEC
--   SAT_MOTOR_AUG_RISK_MOTOR_USAGE_PLAN
--   SAT_QUOTE_RATING_INPUT
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_PROPOSAL_RISK_OBJECT
--   LNK_QUOTE_PROPOSAL
--   LNK_QUOTE_RISK_OBJECT
--   LNK_RISK_OBJECT_LOCATION
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: BA_PART_QUOTE_MOT_PREM
    select
        cast(null as varchar) as LOCATION_BK,
        cast(null as varchar) as PROPOSAL_BK,
        nullif(nullif(trim(to_char(t0.reference_id)), ''), '') as QUOTE_BK,
        cast(null as varchar) as RISK_OBJECT_BK,
        cast(null as number) as __LNK_PROPOSAL_RISK_OBJECT,
        cast(null as number) as __LNK_QUOTE_PROPOSAL,
        cast(null as number) as __LNK_QUOTE_RISK_OBJECT,
        cast(null as number) as __LNK_RISK_OBJECT_LOCATION,
        cast(null as varchar) as AUG_QUOTE_COVERAGE_LINE__COVERAGE_REFERENCE_CK,
        cast(null as varchar) as AUG_QUOTE_COVERAGE_LINE__CGST_AMOUNT,
        cast(null as varchar) as AUG_QUOTE_COVERAGE_LINE__COVERAGE_RATE,
        cast(null as varchar) as AUG_QUOTE_COVERAGE_LINE__COVERAGE_SEQUENCE,
        cast(null as varchar) as AUG_QUOTE_COVERAGE_LINE__DISCOUNT_AMOUNT,
        cast(null as varchar) as AUG_QUOTE_COVERAGE_LINE__DISCOUNT_ENABLED_INDICATOR,
        cast(null as varchar) as AUG_QUOTE_COVERAGE_LINE__EXCESS_AMOUNT,
        cast(null as varchar) as AUG_QUOTE_COVERAGE_LINE__IGST_AMOUNT,
        cast(null as varchar) as AUG_QUOTE_COVERAGE_LINE__LOADING_AMOUNT,
        cast(null as varchar) as AUG_QUOTE_COVERAGE_LINE__PERSONS_COVERED_COUNT,
        cast(null as varchar) as AUG_QUOTE_COVERAGE_LINE__PREMIUM_FOR_COVERAGE,
        cast(null as varchar) as AUG_QUOTE_COVERAGE_LINE__SGST_AMOUNT,
        cast(null as varchar) as AUG_QUOTE_COVERAGE_LINE__SUM_INSURED,
        t0.param_ref as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        cast(null as varchar) as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        cast(null as varchar) as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        t0.param_type as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_COMPONENT,
        t0.param_ref as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE,
        cast(null as varchar) as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_NAME,
        cast(null as varchar) as AUG_QUOTE_VEHICLE_SPEC__CNG_LPG_KIT_VALUE,
        cast(null as varchar) as AUG_QUOTE_VEHICLE_SPEC__FIBRE_GLASS_FITMENT_VALUE,
        cast(null as varchar) as AUG_QUOTE_VEHICLE_SPEC__SIDE_CAR_IDV,
        cast(null as varchar) as AUG_QUOTE_VEHICLE_SPEC__TRAILER_COUNT,
        cast(null as varchar) as AUG_RISK_MOTOR_USAGE_PLAN__PLAN_CODE_CK,
        cast(null as varchar) as AUG_RISK_MOTOR_USAGE_PLAN__PLAN_ELECTION_INDICATOR,
        cast(null as varchar) as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        cast(null as varchar) as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_part_quote_mot_prem') }} t0
    where (nullif(nullif(trim(to_char(t0.reference_id)), ''), '')) is not null

    union all

    -- branch 1: BA_PART_QUOTE_MOT_PREM | child-key literal(s): AUG_QUOTE_PREMIUM_HEAD.Section=OD
    select
        null, null,
        nullif(nullif(trim(to_char(t0.reference_id)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.param_ref as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        t0.od as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_part_quote_mot_prem') }} t0
    where (nullif(nullif(trim(to_char(t0.reference_id)), ''), '')) is not null

    union all

    -- branch 2: BA_PART_QUOTE_MOT_PREM | child-key literal(s): AUG_QUOTE_PREMIUM_HEAD.Section=ACT
    select
        null, null,
        nullif(nullif(trim(to_char(t0.reference_id)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.param_ref as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        'ACT' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        t0.act as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_part_quote_mot_prem') }} t0
    where (nullif(nullif(trim(to_char(t0.reference_id)), ''), '')) is not null

    union all

    -- branch 3: BA_PART_QUOTE_MOT_PREM | child-key literal(s): AUG_QUOTE_PREMIUM_HEAD.Section=NET
    select
        null, null,
        nullif(nullif(trim(to_char(t0.reference_id)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.param_ref as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        'NET' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        t0.net as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_part_quote_mot_prem') }} t0
    where (nullif(nullif(trim(to_char(t0.reference_id)), ''), '')) is not null

    union all

    -- branch 4: BA_QUOTE_MOT_COVERS
    select
        null, null,
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as QUOTE_BK,
        null, null, null, null, null,
        t0.cover_code as AUG_QUOTE_COVERAGE_LINE__COVERAGE_REFERENCE_CK,
        t0.cgst_amt as AUG_QUOTE_COVERAGE_LINE__CGST_AMOUNT,
        t0.cover_rate as AUG_QUOTE_COVERAGE_LINE__COVERAGE_RATE,
        t0.cover_no as AUG_QUOTE_COVERAGE_LINE__COVERAGE_SEQUENCE,
        t0.cover_disc as AUG_QUOTE_COVERAGE_LINE__DISCOUNT_AMOUNT,
        t0.enable_disc as AUG_QUOTE_COVERAGE_LINE__DISCOUNT_ENABLED_INDICATOR,
        t0.voluntary_excess as AUG_QUOTE_COVERAGE_LINE__EXCESS_AMOUNT,
        t0.igst_amt as AUG_QUOTE_COVERAGE_LINE__IGST_AMOUNT,
        t0.cover_load as AUG_QUOTE_COVERAGE_LINE__LOADING_AMOUNT,
        null,
        t0.cover_prem as AUG_QUOTE_COVERAGE_LINE__PREMIUM_FOR_COVERAGE,
        t0.sgst_amt as AUG_QUOTE_COVERAGE_LINE__SGST_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_quote_mot_covers') }} t0
    where (nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '')) is not null

    union all

    -- branch 5: BA_QUOTE_MOT_DTLS | child-key literal(s): AUG_QUOTE_PREMIUM_HEAD.Premium Head Code=ADDON_PAY_AS_YOU_DRIVE, AUG_QUOTE_PREMIUM_HEAD.Section=ADDON
    select
        null, null,
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ADDON_PAY_AS_YOU_DRIVE' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        'ADDON' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        t0.payc_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_quote_mot_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '')) is not null

    union all

    -- branch 6: BA_QUOTE_MOT_DTLS | child-key literal(s): AUG_RISK_MOTOR_USAGE_PLAN.Plan Code=PAY_AS_YOU_CONSUME_PLAN_A
    select
        null, null, null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.vehicle_reg_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        'PAY_AS_YOU_CONSUME_PLAN_A' as AUG_RISK_MOTOR_USAGE_PLAN__PLAN_CODE_CK,
        t0.payc_plan_a as AUG_RISK_MOTOR_USAGE_PLAN__PLAN_ELECTION_INDICATOR,
        null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_quote_mot_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.vehicle_reg_no), '')), '')) is not null

    union all

    -- branch 7: BA_QUOTE_MOT_DTLS | child-key literal(s): AUG_RISK_MOTOR_USAGE_PLAN.Plan Code=PAY_AS_YOU_GO_PLAN_B
    select
        null, null, null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.vehicle_reg_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        'PAY_AS_YOU_GO_PLAN_B' as AUG_RISK_MOTOR_USAGE_PLAN__PLAN_CODE_CK,
        t0.payg_plan_b as AUG_RISK_MOTOR_USAGE_PLAN__PLAN_ELECTION_INDICATOR,
        null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_quote_mot_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.vehicle_reg_no), '')), '')) is not null

    union all

    -- branch 8: BA_QUOTE_MOT_DTLS | child-key literal(s): AUG_RISK_MOTOR_USAGE_PLAN.Plan Code=PAY_AS_YOU_GO_PLAN_C
    select
        null, null, null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.vehicle_reg_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        'PAY_AS_YOU_GO_PLAN_C' as AUG_RISK_MOTOR_USAGE_PLAN__PLAN_CODE_CK,
        t0.payg_plan_c as AUG_RISK_MOTOR_USAGE_PLAN__PLAN_ELECTION_INDICATOR,
        null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_quote_mot_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.vehicle_reg_no), '')), '')) is not null

    union all

    -- branch 9: BA_QUOTE_MOT_DTLS | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=OWNER_SR_FACTOR
    select
        null, null,
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'OWNER_SR_FACTOR' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.owner_sr_factor as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_quote_mot_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '')) is not null

    union all

    -- branch 10: BA_QUOTE_MOT_DTLS | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=CHDH_FACTOR
    select
        null, null,
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'CHDH_FACTOR' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.chdh_factor as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_quote_mot_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '')) is not null

    union all

    -- branch 11: BA_QUOTE_MOT_DTLS | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=AGE_FACTOR
    select
        null, null,
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'AGE_FACTOR' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.age_factor as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_quote_mot_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '')) is not null

    union all

    -- branch 12: BA_QUOTE_MOT_DTLS | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=PRODUCT_CODE_FACTOR
    select
        null, null,
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'PRODUCT_CODE_FACTOR' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.product_code_factor as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_quote_mot_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '')) is not null

    union all

    -- branch 13: BA_QUOTE_MOT_DTLS | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=IDV_FACTOR
    select
        null, null,
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'IDV_FACTOR' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.idv_factor as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_quote_mot_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '')) is not null

    union all

    -- branch 14: BA_QUOTE_MOT_DTLS | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=MV_FACTOR
    select
        null, null,
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'MV_FACTOR' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.mv_factor as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_quote_mot_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '')) is not null

    union all

    -- branch 15: BA_QUOTE_MOT_DTLS | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=ADDON_MV_FACTOR
    select
        null, null,
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'ADDON_MV_FACTOR' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.addon_mv_factor as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_quote_mot_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '')) is not null

    union all

    -- branch 16: BA_QUOTE_MOT_DTLS | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=MV_OD_FACTOR
    select
        null, null,
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'MV_OD_FACTOR' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.mv_od_factor as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_quote_mot_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '')) is not null

    union all

    -- branch 17: BA_QUOTE_MOT_DTLS | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=OVL_MV_FACTOR
    select
        null, null,
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'OVL_MV_FACTOR' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.ovl_mv_factor as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_quote_mot_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '')) is not null

    union all

    -- branch 18: BA_QUOTE_MOT_DTLS
    select
        nullif(nullif(trim(to_char(t0.pincode)), ''), '') as LOCATION_BK,
        null,
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as QUOTE_BK,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.vehicle_reg_no), '')), '') as RISK_OBJECT_BK,
        null, null,
        1 as __LNK_QUOTE_RISK_OBJECT,
        1 as __LNK_RISK_OBJECT_LOCATION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_quote_mot_dtls') }} t0
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.vehicle_reg_no), '')), ''), nullif(nullif(trim(to_char(t0.pincode)), ''), ''), nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), ''))) is not null

    union all

    -- branch 19: BA_QUOTE_MOT_PREM
    select
        null, null,
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.param_ref as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null, null,
        t0.param_type as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_COMPONENT,
        t0.param_ref as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_quote_mot_prem') }} t0
    where (nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '')) is not null

    union all

    -- branch 20: BA_QUOTE_MOT_PREM | child-key literal(s): AUG_QUOTE_PREMIUM_HEAD.Section=OD
    select
        null, null,
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.param_ref as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        t0.od as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_quote_mot_prem') }} t0
    where (nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '')) is not null

    union all

    -- branch 21: BA_QUOTE_MOT_PREM | child-key literal(s): AUG_QUOTE_PREMIUM_HEAD.Section=ACT
    select
        null, null,
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.param_ref as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        'ACT' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        t0.act as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_quote_mot_prem') }} t0
    where (nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '')) is not null

    union all

    -- branch 22: BA_QUOTE_MOT_PREM | child-key literal(s): AUG_QUOTE_PREMIUM_HEAD.Section=NET
    select
        null, null,
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.param_ref as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        'NET' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        t0.net as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_quote_mot_prem') }} t0
    where (nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '')) is not null

    union all

    -- branch 23: BGIL_MOTOR_WS_DETARIFF_EQM | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=VEH_PURCHASE_TYPE
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'VEH_PURCHASE_TYPE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.veh_purchase_type as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_ws_detariff_eqm') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 24: BGIL_MOTOR_WS_DETARIFF_EQM | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=VEH_PURCHASE_DATE
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'VEH_PURCHASE_DATE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.veh_purchase_date as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_ws_detariff_eqm') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 25: BGIL_MOTOR_WS_DETARIFF_EQM | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=MONTH_OF_MFG
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'MONTH_OF_MFG' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.month_of_mfg as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_ws_detariff_eqm') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 26: BGIL_MOTOR_WS_DETARIFF_EQM | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=BODY_TYPE
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'BODY_TYPE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.body_type as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_ws_detariff_eqm') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 27: BGIL_MOTOR_WS_DETARIFF_EQM | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=GOODS_TRANS_TYPE
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'GOODS_TRANS_TYPE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.goods_trans_type as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_ws_detariff_eqm') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 28: BGIL_MOTOR_WS_DETARIFF_EQM | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=NATURE_OF_GOODS
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'NATURE_OF_GOODS' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.nature_of_goods as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_ws_detariff_eqm') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 29: BGIL_MOTOR_WS_DETARIFF_EQM | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=OTHER_GOODS_FREQUENCY
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'OTHER_GOODS_FREQUENCY' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.other_goods_frequency as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_ws_detariff_eqm') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 30: BGIL_MOTOR_WS_DETARIFF_EQM | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=PERMIT_TYPE
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'PERMIT_TYPE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.permit_type as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_ws_detariff_eqm') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 31: BGIL_MOTOR_WS_DETARIFF_EQM | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=ROAD_TYPE
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'ROAD_TYPE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.road_type as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_ws_detariff_eqm') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 32: BGIL_MOTOR_WS_DETARIFF_EQM | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=VEH_DRIVEN_BY
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'VEH_DRIVEN_BY' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.veh_driven_by as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_ws_detariff_eqm') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 33: BGIL_MOTOR_WS_DETARIFF_EQM | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=DRIVER_EXPERIENCE
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'DRIVER_EXPERIENCE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.driver_experience as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_ws_detariff_eqm') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 34: BGIL_MOTOR_WS_DETARIFF_EQM | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=HIST_CODE
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'HIST_CODE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.clm_hist_code as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_ws_detariff_eqm') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 35: BGIL_MOTOR_WS_DETARIFF_EQM | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=INCURRED_CLM_EXP_CODE
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'INCURRED_CLM_EXP_CODE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.incurred_clm_exp_code as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_ws_detariff_eqm') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 36: BGIL_MOTOR_WS_DETARIFF_EQM | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=DRIVER_QUALIFICATION_CODE
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'DRIVER_QUALIFICATION_CODE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.driver_qualification_code as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_ws_detariff_eqm') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 37: BGIL_MOTOR_WS_DETARIFF_EQM | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=TAC_MAKE_CODE
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'TAC_MAKE_CODE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.tac_make_code as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_ws_detariff_eqm') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 38: BGIL_MOTOR_WS_DETARIFF_EQM | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=REGISTRATION_AUTH
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'REGISTRATION_AUTH' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.registration_auth as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_ws_detariff_eqm') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 39: BGIL_MOTWS_OTHER_DTLS_EQM | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=OWNER_SR_FACTOR
    select
        null, null,
        nullif(nullif(trim(to_char(t0.ptransaction_id)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'OWNER_SR_FACTOR' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.owner_sr_factor as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motws_other_dtls_eqm') }} t0
    where (nullif(nullif(trim(to_char(t0.ptransaction_id)), ''), '')) is not null

    union all

    -- branch 40: BGIL_MOTWS_OTHER_DTLS_EQM | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=CHDH_FACTOR
    select
        null, null,
        nullif(nullif(trim(to_char(t0.ptransaction_id)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'CHDH_FACTOR' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.chdh_factor as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motws_other_dtls_eqm') }} t0
    where (nullif(nullif(trim(to_char(t0.ptransaction_id)), ''), '')) is not null

    union all

    -- branch 41: BGIL_MOTWS_OTHER_DTLS_EQM | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=AGE_FACTOR
    select
        null, null,
        nullif(nullif(trim(to_char(t0.ptransaction_id)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'AGE_FACTOR' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.age_factor as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motws_other_dtls_eqm') }} t0
    where (nullif(nullif(trim(to_char(t0.ptransaction_id)), ''), '')) is not null

    union all

    -- branch 42: BGIL_MOTWS_OTHER_DTLS_EQM | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=PRODUCT_CODE_FACTOR
    select
        null, null,
        nullif(nullif(trim(to_char(t0.ptransaction_id)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'PRODUCT_CODE_FACTOR' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.product_code_factor as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motws_other_dtls_eqm') }} t0
    where (nullif(nullif(trim(to_char(t0.ptransaction_id)), ''), '')) is not null

    union all

    -- branch 43: BGIL_MOTWS_OTHER_DTLS_EQM | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=IDV_FACTOR
    select
        null, null,
        nullif(nullif(trim(to_char(t0.ptransaction_id)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'IDV_FACTOR' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.idv_factor as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motws_other_dtls_eqm') }} t0
    where (nullif(nullif(trim(to_char(t0.ptransaction_id)), ''), '')) is not null

    union all

    -- branch 44: BGIL_MOTWS_OTHER_DTLS_EQM
    select
        null,
        nullif(nullif(trim(to_char(t0.ptransaction_id)), ''), '') as PROPOSAL_BK,
        nullif(nullif(trim(to_char(t0.ptransaction_id)), ''), '') as QUOTE_BK,
        nullif(nullif(trim(t0.reg_no), ''), '') as RISK_OBJECT_BK,
        1 as __LNK_PROPOSAL_RISK_OBJECT,
        1 as __LNK_QUOTE_PROPOSAL,
        1 as __LNK_QUOTE_RISK_OBJECT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motws_other_dtls_eqm') }} t0
    where (coalesce(nullif(nullif(trim(t0.reg_no), ''), ''), nullif(nullif(trim(to_char(t0.ptransaction_id)), ''), ''), nullif(nullif(trim(to_char(t0.ptransaction_id)), ''), ''))) is not null

    union all

    -- branch 45: BJAZ_MOTOR_WS_DETARIFF | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=VEH_PURCHASE_TYPE
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'VEH_PURCHASE_TYPE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.veh_purchase_type as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_detariff') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 46: BJAZ_MOTOR_WS_DETARIFF | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=VEH_PURCHASE_DATE
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'VEH_PURCHASE_DATE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.veh_purchase_date as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_detariff') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 47: BJAZ_MOTOR_WS_DETARIFF | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=MONTH_OF_MFG
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'MONTH_OF_MFG' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.month_of_mfg as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_detariff') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 48: BJAZ_MOTOR_WS_DETARIFF | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=BODY_TYPE
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'BODY_TYPE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.body_type as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_detariff') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 49: BJAZ_MOTOR_WS_DETARIFF | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=GOODS_TRANS_TYPE
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'GOODS_TRANS_TYPE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.goods_trans_type as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_detariff') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 50: BJAZ_MOTOR_WS_DETARIFF | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=NATURE_OF_GOODS
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'NATURE_OF_GOODS' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.nature_of_goods as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_detariff') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 51: BJAZ_MOTOR_WS_DETARIFF | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=OTHER_GOODS_FREQUENCY
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'OTHER_GOODS_FREQUENCY' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.other_goods_frequency as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_detariff') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 52: BJAZ_MOTOR_WS_DETARIFF | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=PERMIT_TYPE
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'PERMIT_TYPE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.permit_type as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_detariff') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 53: BJAZ_MOTOR_WS_DETARIFF | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=ROAD_TYPE
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'ROAD_TYPE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.road_type as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_detariff') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 54: BJAZ_MOTOR_WS_DETARIFF | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=VEH_DRIVEN_BY
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'VEH_DRIVEN_BY' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.veh_driven_by as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_detariff') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 55: BJAZ_MOTOR_WS_DETARIFF | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=DRIVER_EXPERIENCE
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'DRIVER_EXPERIENCE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.driver_experience as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_detariff') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 56: BJAZ_MOTOR_WS_DETARIFF | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=HIST_CODE
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'HIST_CODE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.clm_hist_code as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_detariff') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 57: BJAZ_MOTOR_WS_DETARIFF | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=INCURRED_CLM_EXP_CODE
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'INCURRED_CLM_EXP_CODE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.incurred_clm_exp_code as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_detariff') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 58: BJAZ_MOTOR_WS_DETARIFF | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=DRIVER_QUALIFICATION_CODE
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'DRIVER_QUALIFICATION_CODE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.driver_qualification_code as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_detariff') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 59: BJAZ_MOTOR_WS_DETARIFF | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=TAC_MAKE_CODE
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'TAC_MAKE_CODE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.tac_make_code as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_detariff') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 60: BJAZ_MOTOR_WS_DETARIFF | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=REGISTRATION_AUTH
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'REGISTRATION_AUTH' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.registration_auth as QUOTE_RATING_INPUT__FACTOR_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_detariff') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 61: BJAZ_MOTOR_WS_EXTRA_COVERS | child-key literal(s): AUG_QUOTE_COVERAGE_LINE.Coverage Reference=PA_OCCUPANT
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null,
        'PA_OCCUPANT' as AUG_QUOTE_COVERAGE_LINE__COVERAGE_REFERENCE_CK,
        null, null, null, null, null, null, null, null,
        t0.no_of_persons_pa as AUG_QUOTE_COVERAGE_LINE__PERSONS_COVERED_COUNT,
        null, null,
        t0.sum_insured_pa as AUG_QUOTE_COVERAGE_LINE__SUM_INSURED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_extra_covers') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 62: BJAZ_MOTOR_WS_EXTRA_COVERS | child-key literal(s): AUG_QUOTE_COVERAGE_LINE.Coverage Reference=PA_NAMED_PERSON
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null,
        'PA_NAMED_PERSON' as AUG_QUOTE_COVERAGE_LINE__COVERAGE_REFERENCE_CK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.sum_insured_total_named_pa as AUG_QUOTE_COVERAGE_LINE__SUM_INSURED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_extra_covers') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 63: BJAZ_MOTOR_WS_EXTRA_COVERS | child-key literal(s): AUG_QUOTE_COVERAGE_LINE.Coverage Reference=LL_OTHER_EMPLOYEE
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null,
        'LL_OTHER_EMPLOYEE' as AUG_QUOTE_COVERAGE_LINE__COVERAGE_REFERENCE_CK,
        null, null, null, null, null, null, null, null,
        t0.no_of_employees_lle as AUG_QUOTE_COVERAGE_LINE__PERSONS_COVERED_COUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_extra_covers') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 64: BJAZ_MOTOR_WS_EXTRA_COVERS | child-key literal(s): AUG_QUOTE_COVERAGE_LINE.Coverage Reference=LL_OTHER_PERSON
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null,
        'LL_OTHER_PERSON' as AUG_QUOTE_COVERAGE_LINE__COVERAGE_REFERENCE_CK,
        null, null, null, null, null, null, null, null,
        t0.no_of_persons_llo as AUG_QUOTE_COVERAGE_LINE__PERSONS_COVERED_COUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_extra_covers') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 65: BJAZ_MOTOR_WS_EXTRA_COVERS | child-key literal(s): AUG_QUOTE_COVERAGE_LINE.Coverage Reference=TRAILER
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null,
        'TRAILER' as AUG_QUOTE_COVERAGE_LINE__COVERAGE_REFERENCE_CK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.total_trailer_value as AUG_QUOTE_COVERAGE_LINE__SUM_INSURED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_extra_covers') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 66: BJAZ_MOTOR_WS_EXTRA_COVERS | child-key literal(s): AUG_QUOTE_COVERAGE_LINE.Coverage Reference=VOLUNTARY_EXCESS
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null,
        'VOLUNTARY_EXCESS' as AUG_QUOTE_COVERAGE_LINE__COVERAGE_REFERENCE_CK,
        null, null, null, null, null,
        t0.voluntary_excess as AUG_QUOTE_COVERAGE_LINE__EXCESS_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_extra_covers') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 67: BJAZ_MOTOR_WS_EXTRA_COVERS
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.cng_value as AUG_QUOTE_VEHICLE_SPEC__CNG_LPG_KIT_VALUE,
        t0.fibre_glass_value as AUG_QUOTE_VEHICLE_SPEC__FIBRE_GLASS_FITMENT_VALUE,
        t0.side_car_value as AUG_QUOTE_VEHICLE_SPEC__SIDE_CAR_IDV,
        t0.no_of_trailers as AUG_QUOTE_VEHICLE_SPEC__TRAILER_COUNT,
        null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_extra_covers') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 68: BJAZ_MOTOR_WS_PREMIUM_SUMMARY
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.param_ref as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null, null,
        t0.param_type as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_COMPONENT,
        t0.param_ref as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE,
        t0.param_desc as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_NAME,
        null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_premium_summary') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 69: BJAZ_MOTOR_WS_PREMIUM_SUMMARY | child-key literal(s): AUG_QUOTE_PREMIUM_HEAD.Section=OD
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.param_ref as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        t0.od as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_premium_summary') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 70: BJAZ_MOTOR_WS_PREMIUM_SUMMARY | child-key literal(s): AUG_QUOTE_PREMIUM_HEAD.Section=ACT
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.param_ref as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        'ACT' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        t0.act as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_premium_summary') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 71: BJAZ_MOTOR_WS_PREMIUM_SUMMARY | child-key literal(s): AUG_QUOTE_PREMIUM_HEAD.Section=NET
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.param_ref as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        'NET' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        t0.net as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_premium_summary') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

)

select
    LOCATION_BK,
    PROPOSAL_BK,
    QUOTE_BK,
    RISK_OBJECT_BK,
    __LNK_PROPOSAL_RISK_OBJECT,
    __LNK_QUOTE_PROPOSAL,
    __LNK_QUOTE_RISK_OBJECT,
    __LNK_RISK_OBJECT_LOCATION,
    AUG_QUOTE_COVERAGE_LINE__COVERAGE_REFERENCE_CK,
    first_value(AUG_QUOTE_COVERAGE_LINE__CGST_AMOUNT) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_COVERAGE_LINE__COVERAGE_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_COVERAGE_LINE__CGST_AMOUNT,
    first_value(AUG_QUOTE_COVERAGE_LINE__COVERAGE_RATE) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_COVERAGE_LINE__COVERAGE_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_COVERAGE_LINE__COVERAGE_RATE,
    first_value(AUG_QUOTE_COVERAGE_LINE__COVERAGE_SEQUENCE) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_COVERAGE_LINE__COVERAGE_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_COVERAGE_LINE__COVERAGE_SEQUENCE,
    first_value(AUG_QUOTE_COVERAGE_LINE__DISCOUNT_AMOUNT) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_COVERAGE_LINE__COVERAGE_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_COVERAGE_LINE__DISCOUNT_AMOUNT,
    first_value(AUG_QUOTE_COVERAGE_LINE__DISCOUNT_ENABLED_INDICATOR) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_COVERAGE_LINE__COVERAGE_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_COVERAGE_LINE__DISCOUNT_ENABLED_INDICATOR,
    first_value(AUG_QUOTE_COVERAGE_LINE__EXCESS_AMOUNT) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_COVERAGE_LINE__COVERAGE_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_COVERAGE_LINE__EXCESS_AMOUNT,
    first_value(AUG_QUOTE_COVERAGE_LINE__IGST_AMOUNT) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_COVERAGE_LINE__COVERAGE_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_COVERAGE_LINE__IGST_AMOUNT,
    first_value(AUG_QUOTE_COVERAGE_LINE__LOADING_AMOUNT) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_COVERAGE_LINE__COVERAGE_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_COVERAGE_LINE__LOADING_AMOUNT,
    first_value(AUG_QUOTE_COVERAGE_LINE__PERSONS_COVERED_COUNT) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_COVERAGE_LINE__COVERAGE_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_COVERAGE_LINE__PERSONS_COVERED_COUNT,
    first_value(AUG_QUOTE_COVERAGE_LINE__PREMIUM_FOR_COVERAGE) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_COVERAGE_LINE__COVERAGE_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_COVERAGE_LINE__PREMIUM_FOR_COVERAGE,
    first_value(AUG_QUOTE_COVERAGE_LINE__SGST_AMOUNT) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_COVERAGE_LINE__COVERAGE_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_COVERAGE_LINE__SGST_AMOUNT,
    first_value(AUG_QUOTE_COVERAGE_LINE__SUM_INSURED) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_COVERAGE_LINE__COVERAGE_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_COVERAGE_LINE__SUM_INSURED,
    AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
    AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
    first_value(AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, AUG_QUOTE_PREMIUM_HEAD__SECTION_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
    first_value(AUG_QUOTE_PREMIUM_HEAD__PREMIUM_COMPONENT) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, AUG_QUOTE_PREMIUM_HEAD__SECTION_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_COMPONENT,
    first_value(AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, AUG_QUOTE_PREMIUM_HEAD__SECTION_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE,
    first_value(AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_NAME) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, AUG_QUOTE_PREMIUM_HEAD__SECTION_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_NAME,
    first_value(AUG_QUOTE_VEHICLE_SPEC__CNG_LPG_KIT_VALUE) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_VEHICLE_SPEC__CNG_LPG_KIT_VALUE,
    first_value(AUG_QUOTE_VEHICLE_SPEC__FIBRE_GLASS_FITMENT_VALUE) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_VEHICLE_SPEC__FIBRE_GLASS_FITMENT_VALUE,
    first_value(AUG_QUOTE_VEHICLE_SPEC__SIDE_CAR_IDV) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_VEHICLE_SPEC__SIDE_CAR_IDV,
    first_value(AUG_QUOTE_VEHICLE_SPEC__TRAILER_COUNT) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_VEHICLE_SPEC__TRAILER_COUNT,
    AUG_RISK_MOTOR_USAGE_PLAN__PLAN_CODE_CK,
    first_value(AUG_RISK_MOTOR_USAGE_PLAN__PLAN_ELECTION_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK, AUG_RISK_MOTOR_USAGE_PLAN__PLAN_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_USAGE_PLAN__PLAN_ELECTION_INDICATOR,
    QUOTE_RATING_INPUT__FACTOR_CODE_CK,
    first_value(QUOTE_RATING_INPUT__FACTOR_VALUE) ignore nulls over (partition by QUOTE_BK, QUOTE_RATING_INPUT__FACTOR_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as QUOTE_RATING_INPUT__FACTOR_VALUE,
    -- the row's own source time: LOAD_DATETIME for hubs, links and single-active satellites
    m.INC_JOB_UPDATED_AT,
    -- multi-active satellites on QUOTE_BK (SAT_MOTOR_AUG_QUOTE_COVERAGE_LINE, SAT_MOTOR_AUG_QUOTE_PREMIUM_HEAD, SAT_QUOTE_RATING_INPUT):
    -- one load time per QUOTE_BK, the newest INC_JOB_UPDATED_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.AUG_QUOTE_COVERAGE_LINE__CGST_AMOUNT, m.AUG_QUOTE_COVERAGE_LINE__COVERAGE_RATE, m.AUG_QUOTE_COVERAGE_LINE__COVERAGE_SEQUENCE, m.AUG_QUOTE_COVERAGE_LINE__DISCOUNT_AMOUNT, m.AUG_QUOTE_COVERAGE_LINE__DISCOUNT_ENABLED_INDICATOR, m.AUG_QUOTE_COVERAGE_LINE__EXCESS_AMOUNT, m.AUG_QUOTE_COVERAGE_LINE__IGST_AMOUNT, m.AUG_QUOTE_COVERAGE_LINE__LOADING_AMOUNT, m.AUG_QUOTE_COVERAGE_LINE__PERSONS_COVERED_COUNT, m.AUG_QUOTE_COVERAGE_LINE__PREMIUM_FOR_COVERAGE, m.AUG_QUOTE_COVERAGE_LINE__SGST_AMOUNT, m.AUG_QUOTE_COVERAGE_LINE__SUM_INSURED, m.AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM, m.AUG_QUOTE_PREMIUM_HEAD__PREMIUM_COMPONENT, m.AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE, m.AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_NAME, m.QUOTE_RATING_INPUT__FACTOR_VALUE) is not null
             then m.INC_JOB_UPDATED_AT end)
        over (partition by m.QUOTE_BK) as QUOTE_BK__MA_LOAD_DATETIME,
    -- multi-active satellites on RISK_OBJECT_BK (SAT_MOTOR_AUG_RISK_MOTOR_USAGE_PLAN):
    -- one load time per RISK_OBJECT_BK, the newest INC_JOB_UPDATED_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when m.AUG_RISK_MOTOR_USAGE_PLAN__PLAN_ELECTION_INDICATOR is not null
             then m.INC_JOB_UPDATED_AT end)
        over (partition by m.RISK_OBJECT_BK) as RISK_OBJECT_BK__MA_LOAD_DATETIME
from merged m
