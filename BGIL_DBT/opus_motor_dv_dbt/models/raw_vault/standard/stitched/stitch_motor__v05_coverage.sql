-- CENTRAL VIEW v05_coverage -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   BA_QUOTE_MOT_COVERS
--   BJAZ_MOT_COVER_EXTN
--   BJAZ_MOT_NAMED_DRIVER_EXTN
--   BJAZ_MOT_ONLINE_POL_DTLS
--   BJAZ_MOT_PAYC_DTLS
--   BJAZ_MOT_PROD_UIN_MAPPING
--   BJAZ_MOT_RENEWAL_HIST
--   BJAZ_MOT_WAR_CHILD_DTLS
--   BJAZ_MOT_WAR_PLANS_EXTN
--   BJAZ_MOT_WS_POL_DTLS
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_COVERAGE_MOTOR_ADDON_PARAMS
--   SAT_AUG_COVERAGE_MOTOR_LAID_UP
--   SAT_AUG_POLICY_COVERAGE_SCHEDULE
--   SAT_AUG_PRODUCT_TERMS
--   SAT_AUG_RISK_MOTOR_DRIVER
--   SAT_COVERAGE_MOTOR_PA_OCCUPANT
--   SAT_POLICY_COVERAGE_SCHEDULE
--   SAT_POLICY_TERMS
--   SAT_PRODUCT_DEFINITION
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_POLICY_COVERAGE
--   LNK_POLICY_COVERAGE_RISK
--   LNK_POLICY_RISK_OBJECT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: BA_QUOTE_MOT_COVERS | child-key literal(s): AUG_COVERAGE_MOTOR_ADDON_PARAMS.Add-On Coverage Code=TYRE_COVER, AUG_COVERAGE_MOTOR_ADDON_PARAMS.Tyre Position=WHEEL_1
    select
        nullif(nullif(trim(t0.cover_code), ''), '') as COVERAGE_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        cast(null as varchar) as RISK_OBJECT_BK,
        cast(null as number) as __LNK_POLICY_COVERAGE,
        cast(null as number) as __LNK_POLICY_COVERAGE_RISK,
        cast(null as number) as __LNK_POLICY_RISK_OBJECT,
        'TYRE_COVER' as AUG_COVERAGE_MOTOR_ADDON_PARAMS__ADD_ON_COVERAGE_CODE_CK,
        'WHEEL_1' as AUG_COVERAGE_MOTOR_ADDON_PARAMS__TYRE_POSITION_CK,
        t0.tyre1 as AUG_COVERAGE_MOTOR_ADDON_PARAMS__TYRE_DESCRIPTION,
        cast(null as varchar) as AUG_COVERAGE_MOTOR_ADDON_PARAMS__TYRE_DETAIL,
        cast(null as varchar) as AUG_COVERAGE_MOTOR_LAID_UP__LAID_UP_END_DATE,
        cast(null as varchar) as AUG_COVERAGE_MOTOR_LAID_UP__LAID_UP_START_DATE,
        cast(null as varchar) as AUG_COVERAGE_MOTOR_LAID_UP__LAID_UP_SUB_TYPE,
        cast(null as varchar) as AUG_COVERAGE_MOTOR_LAID_UP__LAID_UP_TYPE,
        cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK,
        cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_RATE,
        cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__SOURCE_LINE_REFERENCE,
        cast(null as varchar) as AUG_PRODUCT_TERMS__APPLICABILITY_FUEL_TYPE,
        cast(null as varchar) as AUG_PRODUCT_TERMS__APPLICABILITY_VEHICLE_MAKE,
        cast(null as varchar) as AUG_PRODUCT_TERMS__APPLICABILITY_VEHICLE_MODEL,
        cast(null as varchar) as AUG_PRODUCT_TERMS__CEILING_KILOMETRE_READING,
        cast(null as varchar) as AUG_PRODUCT_TERMS__CEILING_RUNNING_HOUR_READING,
        cast(null as varchar) as AUG_PRODUCT_TERMS__MAXIMUM_VEHICLE_AGE_DAYS,
        cast(null as varchar) as AUG_PRODUCT_TERMS__MILEAGE_LIMIT,
        cast(null as varchar) as AUG_PRODUCT_TERMS__MINIMUM_VEHICLE_AGE_DAYS,
        cast(null as varchar) as AUG_PRODUCT_TERMS__PLAN_EFFECTIVE_FROM_DATE,
        cast(null as varchar) as AUG_PRODUCT_TERMS__RUNNING_HOUR_LIMIT,
        cast(null as varchar) as AUG_PRODUCT_TERMS__WARRANTY_TERM,
        cast(null as varchar) as AUG_RISK_MOTOR_DRIVER__DRIVER_LICENCE_NUMBER_CK,
        cast(null as varchar) as AUG_RISK_MOTOR_DRIVER__DRIVER_ROLE_CK,
        cast(null as varchar) as AUG_RISK_MOTOR_DRIVER__AGE_AT_LICENCE_ISSUE,
        cast(null as varchar) as AUG_RISK_MOTOR_DRIVER__DRIVER_LINE_PARTICULARS,
        cast(null as varchar) as COVERAGE_MOTOR_PA_OCCUPANT__NUMBER_OF_PERSONS_COVERED,
        cast(null as varchar) as COVERAGE_MOTOR_PA_OCCUPANT__PAID_DRIVER_COUNT,
        cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK,
        cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__COVERAGE_OPTED_INDICATOR,
        cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE,
        cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__PREMIUM_FOR_COVERAGE,
        cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__SUM_INSURED,
        cast(null as varchar) as POLICY_TERMS__DEDUCTIBLE_TOTAL,
        cast(null as varchar) as POLICY_TERMS__GEOGRAPHICAL_SCOPE,
        cast(null as varchar) as POLICY_TERMS__SPECIAL_CONDITIONS,
        cast(null as varchar) as POLICY_TERMS__WAITING_PERIOD,
        cast(null as varchar) as PRODUCT_DEFINITION__PRODUCT_DESCRIPTION,
        cast(null as varchar) as PRODUCT_DEFINITION__PRODUCT_NAME,
        cast(null as varchar) as PRODUCT_DEFINITION__PRODUCT_STATUS,
        cast(null as varchar) as PRODUCT_DEFINITION__UIN,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_quote_mot_covers') }} t0
    where (nullif(nullif(trim(t0.cover_code), ''), '')) is not null

    union all

    -- branch 1: BA_QUOTE_MOT_COVERS | child-key literal(s): AUG_COVERAGE_MOTOR_ADDON_PARAMS.Add-On Coverage Code=TYRE_COVER, AUG_COVERAGE_MOTOR_ADDON_PARAMS.Tyre Position=WHEEL_2
    select
        nullif(nullif(trim(t0.cover_code), ''), '') as COVERAGE_BK,
        null, null, null, null, null, null,
        'TYRE_COVER' as AUG_COVERAGE_MOTOR_ADDON_PARAMS__ADD_ON_COVERAGE_CODE_CK,
        'WHEEL_2' as AUG_COVERAGE_MOTOR_ADDON_PARAMS__TYRE_POSITION_CK,
        t0.tyre2 as AUG_COVERAGE_MOTOR_ADDON_PARAMS__TYRE_DESCRIPTION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_quote_mot_covers') }} t0
    where (nullif(nullif(trim(t0.cover_code), ''), '')) is not null

    union all

    -- branch 2: BA_QUOTE_MOT_COVERS | child-key literal(s): AUG_COVERAGE_MOTOR_ADDON_PARAMS.Add-On Coverage Code=TYRE_COVER, AUG_COVERAGE_MOTOR_ADDON_PARAMS.Tyre Position=WHEEL_3
    select
        nullif(nullif(trim(t0.cover_code), ''), '') as COVERAGE_BK,
        null, null, null, null, null, null,
        'TYRE_COVER' as AUG_COVERAGE_MOTOR_ADDON_PARAMS__ADD_ON_COVERAGE_CODE_CK,
        'WHEEL_3' as AUG_COVERAGE_MOTOR_ADDON_PARAMS__TYRE_POSITION_CK,
        t0.tyre3 as AUG_COVERAGE_MOTOR_ADDON_PARAMS__TYRE_DESCRIPTION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_quote_mot_covers') }} t0
    where (nullif(nullif(trim(t0.cover_code), ''), '')) is not null

    union all

    -- branch 3: BA_QUOTE_MOT_COVERS | child-key literal(s): AUG_COVERAGE_MOTOR_ADDON_PARAMS.Add-On Coverage Code=TYRE_COVER, AUG_COVERAGE_MOTOR_ADDON_PARAMS.Tyre Position=WHEEL_4
    select
        nullif(nullif(trim(t0.cover_code), ''), '') as COVERAGE_BK,
        null, null, null, null, null, null,
        'TYRE_COVER' as AUG_COVERAGE_MOTOR_ADDON_PARAMS__ADD_ON_COVERAGE_CODE_CK,
        'WHEEL_4' as AUG_COVERAGE_MOTOR_ADDON_PARAMS__TYRE_POSITION_CK,
        t0.tyre4 as AUG_COVERAGE_MOTOR_ADDON_PARAMS__TYRE_DESCRIPTION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_quote_mot_covers') }} t0
    where (nullif(nullif(trim(t0.cover_code), ''), '')) is not null

    union all

    -- branch 4: BA_QUOTE_MOT_COVERS | child-key literal(s): AUG_COVERAGE_MOTOR_ADDON_PARAMS.Add-On Coverage Code=TYRE_COVER, AUG_COVERAGE_MOTOR_ADDON_PARAMS.Tyre Position=WHEEL_5
    select
        nullif(nullif(trim(t0.cover_code), ''), '') as COVERAGE_BK,
        null, null, null, null, null, null,
        'TYRE_COVER' as AUG_COVERAGE_MOTOR_ADDON_PARAMS__ADD_ON_COVERAGE_CODE_CK,
        'WHEEL_5' as AUG_COVERAGE_MOTOR_ADDON_PARAMS__TYRE_POSITION_CK,
        t0.tyre5 as AUG_COVERAGE_MOTOR_ADDON_PARAMS__TYRE_DESCRIPTION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_quote_mot_covers') }} t0
    where (nullif(nullif(trim(t0.cover_code), ''), '')) is not null

    union all

    -- branch 5: BA_QUOTE_MOT_COVERS
    select
        nullif(nullif(trim(t0.cover_code), ''), '') as COVERAGE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.pa_no_of_persons as COVERAGE_MOTOR_PA_OCCUPANT__NUMBER_OF_PERSONS_COVERED,
        t0.pa_no_drv_cl as COVERAGE_MOTOR_PA_OCCUPANT__PAID_DRIVER_COUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_quote_mot_covers') }} t0
    where (nullif(nullif(trim(t0.cover_code), ''), '')) is not null

    union all

    -- branch 6: BJAZ_MOT_COVER_EXTN | child-key literal(s): AUG_COVERAGE_MOTOR_ADDON_PARAMS.Add-On Coverage Code=TYRE_COVER, AUG_COVERAGE_MOTOR_ADDON_PARAMS.Tyre Position=WHEEL_1
    select
        nullif(nullif(coalesce(nullif(trim(to_char(t0.contract_id)), ''), '') || '|' || coalesce(nullif(trim(t0.cover_code), ''), '') || '|' || coalesce(nullif(trim(to_char(t0.cover_no)), ''), ''), '||'), '') as COVERAGE_BK,
        null, null, null, null, null, null,
        'TYRE_COVER' as AUG_COVERAGE_MOTOR_ADDON_PARAMS__ADD_ON_COVERAGE_CODE_CK,
        'WHEEL_1' as AUG_COVERAGE_MOTOR_ADDON_PARAMS__TYRE_POSITION_CK,
        null,
        t0.tyre1 as AUG_COVERAGE_MOTOR_ADDON_PARAMS__TYRE_DETAIL,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_cover_extn') }} t0
    where (nullif(nullif(coalesce(nullif(trim(to_char(t0.contract_id)), ''), '') || '|' || coalesce(nullif(trim(t0.cover_code), ''), '') || '|' || coalesce(nullif(trim(to_char(t0.cover_no)), ''), ''), '||'), '')) is not null

    union all

    -- branch 7: BJAZ_MOT_COVER_EXTN | child-key literal(s): AUG_COVERAGE_MOTOR_ADDON_PARAMS.Add-On Coverage Code=TYRE_COVER, AUG_COVERAGE_MOTOR_ADDON_PARAMS.Tyre Position=WHEEL_2
    select
        nullif(nullif(coalesce(nullif(trim(to_char(t0.contract_id)), ''), '') || '|' || coalesce(nullif(trim(t0.cover_code), ''), '') || '|' || coalesce(nullif(trim(to_char(t0.cover_no)), ''), ''), '||'), '') as COVERAGE_BK,
        null, null, null, null, null, null,
        'TYRE_COVER' as AUG_COVERAGE_MOTOR_ADDON_PARAMS__ADD_ON_COVERAGE_CODE_CK,
        'WHEEL_2' as AUG_COVERAGE_MOTOR_ADDON_PARAMS__TYRE_POSITION_CK,
        null,
        t0.tyre2 as AUG_COVERAGE_MOTOR_ADDON_PARAMS__TYRE_DETAIL,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_cover_extn') }} t0
    where (nullif(nullif(coalesce(nullif(trim(to_char(t0.contract_id)), ''), '') || '|' || coalesce(nullif(trim(t0.cover_code), ''), '') || '|' || coalesce(nullif(trim(to_char(t0.cover_no)), ''), ''), '||'), '')) is not null

    union all

    -- branch 8: BJAZ_MOT_COVER_EXTN | child-key literal(s): AUG_COVERAGE_MOTOR_ADDON_PARAMS.Add-On Coverage Code=TYRE_COVER, AUG_COVERAGE_MOTOR_ADDON_PARAMS.Tyre Position=WHEEL_3
    select
        nullif(nullif(coalesce(nullif(trim(to_char(t0.contract_id)), ''), '') || '|' || coalesce(nullif(trim(t0.cover_code), ''), '') || '|' || coalesce(nullif(trim(to_char(t0.cover_no)), ''), ''), '||'), '') as COVERAGE_BK,
        null, null, null, null, null, null,
        'TYRE_COVER' as AUG_COVERAGE_MOTOR_ADDON_PARAMS__ADD_ON_COVERAGE_CODE_CK,
        'WHEEL_3' as AUG_COVERAGE_MOTOR_ADDON_PARAMS__TYRE_POSITION_CK,
        null,
        t0.tyre3 as AUG_COVERAGE_MOTOR_ADDON_PARAMS__TYRE_DETAIL,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_cover_extn') }} t0
    where (nullif(nullif(coalesce(nullif(trim(to_char(t0.contract_id)), ''), '') || '|' || coalesce(nullif(trim(t0.cover_code), ''), '') || '|' || coalesce(nullif(trim(to_char(t0.cover_no)), ''), ''), '||'), '')) is not null

    union all

    -- branch 9: BJAZ_MOT_COVER_EXTN | child-key literal(s): AUG_COVERAGE_MOTOR_ADDON_PARAMS.Add-On Coverage Code=TYRE_COVER, AUG_COVERAGE_MOTOR_ADDON_PARAMS.Tyre Position=WHEEL_4
    select
        nullif(nullif(coalesce(nullif(trim(to_char(t0.contract_id)), ''), '') || '|' || coalesce(nullif(trim(t0.cover_code), ''), '') || '|' || coalesce(nullif(trim(to_char(t0.cover_no)), ''), ''), '||'), '') as COVERAGE_BK,
        null, null, null, null, null, null,
        'TYRE_COVER' as AUG_COVERAGE_MOTOR_ADDON_PARAMS__ADD_ON_COVERAGE_CODE_CK,
        'WHEEL_4' as AUG_COVERAGE_MOTOR_ADDON_PARAMS__TYRE_POSITION_CK,
        null,
        t0.tyre4 as AUG_COVERAGE_MOTOR_ADDON_PARAMS__TYRE_DETAIL,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_cover_extn') }} t0
    where (nullif(nullif(coalesce(nullif(trim(to_char(t0.contract_id)), ''), '') || '|' || coalesce(nullif(trim(t0.cover_code), ''), '') || '|' || coalesce(nullif(trim(to_char(t0.cover_no)), ''), ''), '||'), '')) is not null

    union all

    -- branch 10: BJAZ_MOT_COVER_EXTN | child-key literal(s): AUG_COVERAGE_MOTOR_ADDON_PARAMS.Add-On Coverage Code=TYRE_COVER, AUG_COVERAGE_MOTOR_ADDON_PARAMS.Tyre Position=WHEEL_5
    select
        nullif(nullif(coalesce(nullif(trim(to_char(t0.contract_id)), ''), '') || '|' || coalesce(nullif(trim(t0.cover_code), ''), '') || '|' || coalesce(nullif(trim(to_char(t0.cover_no)), ''), ''), '||'), '') as COVERAGE_BK,
        null, null, null, null, null, null,
        'TYRE_COVER' as AUG_COVERAGE_MOTOR_ADDON_PARAMS__ADD_ON_COVERAGE_CODE_CK,
        'WHEEL_5' as AUG_COVERAGE_MOTOR_ADDON_PARAMS__TYRE_POSITION_CK,
        null,
        t0.tyre5 as AUG_COVERAGE_MOTOR_ADDON_PARAMS__TYRE_DETAIL,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_cover_extn') }} t0
    where (nullif(nullif(coalesce(nullif(trim(to_char(t0.contract_id)), ''), '') || '|' || coalesce(nullif(trim(t0.cover_code), ''), '') || '|' || coalesce(nullif(trim(to_char(t0.cover_no)), ''), ''), '||'), '')) is not null

    union all

    -- branch 11: BJAZ_MOT_COVER_EXTN
    select
        nullif(nullif(coalesce(nullif(trim(to_char(t0.contract_id)), ''), '') || '|' || coalesce(nullif(trim(t0.cover_code), ''), '') || '|' || coalesce(nullif(trim(to_char(t0.cover_no)), ''), ''), '||'), '') as COVERAGE_BK,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null,
        1 as __LNK_POLICY_COVERAGE,
        null, null, null, null, null, null,
        t0.laidup_end_dt as AUG_COVERAGE_MOTOR_LAID_UP__LAID_UP_END_DATE,
        t0.laidup_start_dt as AUG_COVERAGE_MOTOR_LAID_UP__LAID_UP_START_DATE,
        t0.laidup_subtype as AUG_COVERAGE_MOTOR_LAID_UP__LAID_UP_SUB_TYPE,
        t0.laidup_type as AUG_COVERAGE_MOTOR_LAID_UP__LAID_UP_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.pa_no_of_persons as COVERAGE_MOTOR_PA_OCCUPANT__NUMBER_OF_PERSONS_COVERED,
        t0.pa_no_drv_cl as COVERAGE_MOTOR_PA_OCCUPANT__PAID_DRIVER_COUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_cover_extn') }} t0
    where (coalesce(nullif(nullif(coalesce(nullif(trim(to_char(t0.contract_id)), ''), '') || '|' || coalesce(nullif(trim(t0.cover_code), ''), '') || '|' || coalesce(nullif(trim(to_char(t0.cover_no)), ''), ''), '||'), ''), nullif(nullif(trim(to_char(t0.contract_id)), ''), ''))) is not null

    union all

    -- branch 12: BJAZ_MOT_COVER_EXTN | child-key literal(s): AUG_POLICY_COVERAGE_SCHEDULE.Coverage Reference=COVER_RATE
    select
        null,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        'COVER_RATE' as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        null,
        t0.cover_rate as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_RATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_cover_extn') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 13: BJAZ_MOT_COVER_EXTN | child-key literal(s): POLICY_COVERAGE_SCHEDULE.Coverage Reference=COVER_NO
    select
        null,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        'COVER_NO' as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        null, null,
        t0.cover_no as POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE,
        null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_cover_extn') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 14: BJAZ_MOT_NAMED_DRIVER_EXTN | child-key literal(s): AUG_POLICY_COVERAGE_SCHEDULE.Coverage Reference=REF_ID
    select
        null,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        'REF_ID' as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        null, null,
        t0.ref_id as AUG_POLICY_COVERAGE_SCHEDULE__SOURCE_LINE_REFERENCE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_named_driver_extn') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 15: BJAZ_MOT_NAMED_DRIVER_EXTN
    select
        nullif(nullif(trim(t0.cover_code), ''), '') as COVERAGE_BK,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null,
        nullif(nullif(trim(to_char(t0.object_id)), ''), '') as RISK_OBJECT_BK,
        1 as __LNK_POLICY_COVERAGE,
        1 as __LNK_POLICY_COVERAGE_RISK,
        1 as __LNK_POLICY_RISK_OBJECT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.driver_licence_no as AUG_RISK_MOTOR_DRIVER__DRIVER_LICENCE_NUMBER_CK,
        null, null,
        t0.particulars as AUG_RISK_MOTOR_DRIVER__DRIVER_LINE_PARTICULARS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_named_driver_extn') }} t0
    where (coalesce(nullif(nullif(trim(t0.cover_code), ''), ''), nullif(nullif(trim(to_char(t0.contract_id)), ''), ''), nullif(nullif(trim(to_char(t0.object_id)), ''), ''))) is not null

    union all

    -- branch 16: BJAZ_MOT_NAMED_DRIVER_EXTN | child-key literal(s): POLICY_COVERAGE_SCHEDULE.Coverage Reference=COVER_NO
    select
        null,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        'COVER_NO' as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        null, null,
        t0.cover_no as POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE,
        null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_named_driver_extn') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 17: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): AUG_RISK_MOTOR_DRIVER.Driver Role=OWNER_DRIVER
    select
        null, null, null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        'OWNER_DRIVER' as AUG_RISK_MOTOR_DRIVER__DRIVER_ROLE_CK,
        t0.age_recived_license as AUG_RISK_MOTOR_DRIVER__AGE_AT_LICENCE_ISSUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 18: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): POLICY_COVERAGE_SCHEDULE.Coverage Reference=PA_COVER_VAL
    select
        null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        'PA_COVER_VAL' as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.pa_cover_val as POLICY_COVERAGE_SCHEDULE__SUM_INSURED,
        null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 19: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): POLICY_COVERAGE_SCHEDULE.Coverage Reference=PACKAGE_A
    select
        null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        'PACKAGE_A' as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        null,
        t0.package_a_yn as POLICY_COVERAGE_SCHEDULE__COVERAGE_OPTED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 20: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): POLICY_COVERAGE_SCHEDULE.Coverage Reference=PACKAGE_B
    select
        null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        'PACKAGE_B' as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        null,
        t0.package_b_yn as POLICY_COVERAGE_SCHEDULE__COVERAGE_OPTED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 21: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): POLICY_COVERAGE_SCHEDULE.Coverage Reference=PACKAGE_C
    select
        null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        'PACKAGE_C' as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        null,
        t0.package_c_yn as POLICY_COVERAGE_SCHEDULE__COVERAGE_OPTED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 22: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): POLICY_COVERAGE_SCHEDULE.Coverage Reference=GROSS_PREMIUM_A
    select
        null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        'GROSS_PREMIUM_A' as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        null, null, null,
        t0.gross_premium_a as POLICY_COVERAGE_SCHEDULE__PREMIUM_FOR_COVERAGE,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 23: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): POLICY_COVERAGE_SCHEDULE.Coverage Reference=GROSS_PREMIUM_B
    select
        null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        'GROSS_PREMIUM_B' as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        null, null, null,
        t0.gross_premium_b as POLICY_COVERAGE_SCHEDULE__PREMIUM_FOR_COVERAGE,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 24: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): POLICY_COVERAGE_SCHEDULE.Coverage Reference=GROSS_PREMIUM_C
    select
        null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        'GROSS_PREMIUM_C' as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        null, null, null,
        t0.gross_premium_c as POLICY_COVERAGE_SCHEDULE__PREMIUM_FOR_COVERAGE,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 25: BJAZ_MOT_ONLINE_POL_DTLS
    select
        null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        nullif(nullif(trim(t0.product_4digit_code), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.geog_extn_code as POLICY_TERMS__GEOGRAPHICAL_SCOPE,
        null, null,
        t0.plan_desc as PRODUCT_DEFINITION__PRODUCT_DESCRIPTION,
        null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (coalesce(nullif(nullif(trim(t0.policy_ref), ''), ''), nullif(nullif(trim(t0.product_4digit_code), ''), ''))) is not null

    union all

    -- branch 26: BJAZ_MOT_PAYC_DTLS
    select
        null,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.waiting_period as POLICY_TERMS__WAITING_PERIOD,
        null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_payc_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 27: BJAZ_MOT_PROD_UIN_MAPPING
    select
        null, null,
        nullif(nullif(trim(to_char(t0.prod_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.prod_desc as PRODUCT_DEFINITION__PRODUCT_DESCRIPTION,
        t0.prod_name as PRODUCT_DEFINITION__PRODUCT_NAME,
        t0.status as PRODUCT_DEFINITION__PRODUCT_STATUS,
        t0.prod_uin as PRODUCT_DEFINITION__UIN,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_prod_uin_mapping') }} t0
    where (nullif(nullif(trim(to_char(t0.prod_code)), ''), '')) is not null

    union all

    -- branch 28: BJAZ_MOT_RENEWAL_HIST
    select
        null,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.deductible as POLICY_TERMS__DEDUCTIBLE_TOTAL,
        null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_hist') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 29: BJAZ_MOT_WAR_CHILD_DTLS
    select
        null,
        nullif(nullif(trim(t0.motor_policy_no), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.special_conditions as POLICY_TERMS__SPECIAL_CONDITIONS,
        null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_war_child_dtls') }} t0
    where (nullif(nullif(trim(t0.motor_policy_no), ''), '')) is not null

    union all

    -- branch 30: BJAZ_MOT_WAR_PLANS_EXTN
    select
        null, null,
        nullif(nullif('WARPLAN:' || nullif(trim(to_char(t0.plan_id)), ''), 'WARPLAN:'), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.fuel_type as AUG_PRODUCT_TERMS__APPLICABILITY_FUEL_TYPE,
        t0.vehicle_make as AUG_PRODUCT_TERMS__APPLICABILITY_VEHICLE_MAKE,
        t0.vehicle_model as AUG_PRODUCT_TERMS__APPLICABILITY_VEHICLE_MODEL,
        t0.ceiling_km as AUG_PRODUCT_TERMS__CEILING_KILOMETRE_READING,
        t0.ceiling_hour as AUG_PRODUCT_TERMS__CEILING_RUNNING_HOUR_READING,
        t0.age_to_days as AUG_PRODUCT_TERMS__MAXIMUM_VEHICLE_AGE_DAYS,
        t0.war_km_limit as AUG_PRODUCT_TERMS__MILEAGE_LIMIT,
        t0.age_from_days as AUG_PRODUCT_TERMS__MINIMUM_VEHICLE_AGE_DAYS,
        t0.effective_from as AUG_PRODUCT_TERMS__PLAN_EFFECTIVE_FROM_DATE,
        t0.war_hour_limit as AUG_PRODUCT_TERMS__RUNNING_HOUR_LIMIT,
        t0.warranty_period as AUG_PRODUCT_TERMS__WARRANTY_TERM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.plan_desc as PRODUCT_DEFINITION__PRODUCT_DESCRIPTION,
        null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_war_plans_extn') }} t0
    where (nullif(nullif('WARPLAN:' || nullif(trim(to_char(t0.plan_id)), ''), 'WARPLAN:'), '')) is not null

    union all

    -- branch 31: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): AUG_RISK_MOTOR_DRIVER.Driver Role=OWNER_DRIVER
    select
        null, null, null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        'OWNER_DRIVER' as AUG_RISK_MOTOR_DRIVER__DRIVER_ROLE_CK,
        t0.age_recived_license as AUG_RISK_MOTOR_DRIVER__AGE_AT_LICENCE_ISSUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 32: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): POLICY_COVERAGE_SCHEDULE.Coverage Reference=PACKAGE_A
    select
        null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        'PACKAGE_A' as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        null,
        t0.package_a_yn as POLICY_COVERAGE_SCHEDULE__COVERAGE_OPTED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 33: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): POLICY_COVERAGE_SCHEDULE.Coverage Reference=PACKAGE_B
    select
        null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        'PACKAGE_B' as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        null,
        t0.package_b_yn as POLICY_COVERAGE_SCHEDULE__COVERAGE_OPTED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 34: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): POLICY_COVERAGE_SCHEDULE.Coverage Reference=PACKAGE_C
    select
        null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        'PACKAGE_C' as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        null,
        t0.package_c_yn as POLICY_COVERAGE_SCHEDULE__COVERAGE_OPTED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 35: BJAZ_MOT_WS_POL_DTLS
    select
        null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        nullif(nullif(trim(to_char(t0.product_4digit_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.trv_area as POLICY_TERMS__GEOGRAPHICAL_SCOPE,
        null, null,
        t0.plan_desc as PRODUCT_DEFINITION__PRODUCT_DESCRIPTION,
        null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (coalesce(nullif(nullif(trim(t0.policy_ref), ''), ''), nullif(nullif(trim(to_char(t0.product_4digit_code)), ''), ''))) is not null

)

select
    COVERAGE_BK,
    POLICY_BK,
    PRODUCT_BK,
    RISK_OBJECT_BK,
    __LNK_POLICY_COVERAGE,
    __LNK_POLICY_COVERAGE_RISK,
    __LNK_POLICY_RISK_OBJECT,
    AUG_COVERAGE_MOTOR_ADDON_PARAMS__ADD_ON_COVERAGE_CODE_CK,
    AUG_COVERAGE_MOTOR_ADDON_PARAMS__TYRE_POSITION_CK,
    first_value(AUG_COVERAGE_MOTOR_ADDON_PARAMS__TYRE_DESCRIPTION) ignore nulls over (partition by COVERAGE_BK, AUG_COVERAGE_MOTOR_ADDON_PARAMS__ADD_ON_COVERAGE_CODE_CK, AUG_COVERAGE_MOTOR_ADDON_PARAMS__TYRE_POSITION_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_MOTOR_ADDON_PARAMS__TYRE_DESCRIPTION,
    first_value(AUG_COVERAGE_MOTOR_ADDON_PARAMS__TYRE_DETAIL) ignore nulls over (partition by COVERAGE_BK, AUG_COVERAGE_MOTOR_ADDON_PARAMS__ADD_ON_COVERAGE_CODE_CK, AUG_COVERAGE_MOTOR_ADDON_PARAMS__TYRE_POSITION_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_MOTOR_ADDON_PARAMS__TYRE_DETAIL,
    first_value(AUG_COVERAGE_MOTOR_LAID_UP__LAID_UP_END_DATE) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_MOTOR_LAID_UP__LAID_UP_END_DATE,
    first_value(AUG_COVERAGE_MOTOR_LAID_UP__LAID_UP_START_DATE) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_MOTOR_LAID_UP__LAID_UP_START_DATE,
    first_value(AUG_COVERAGE_MOTOR_LAID_UP__LAID_UP_SUB_TYPE) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_MOTOR_LAID_UP__LAID_UP_SUB_TYPE,
    first_value(AUG_COVERAGE_MOTOR_LAID_UP__LAID_UP_TYPE) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_MOTOR_LAID_UP__LAID_UP_TYPE,
    AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
    AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK,
    first_value(AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_RATE) ignore nulls over (partition by POLICY_BK, AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_RATE,
    first_value(AUG_POLICY_COVERAGE_SCHEDULE__SOURCE_LINE_REFERENCE) ignore nulls over (partition by POLICY_BK, AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_COVERAGE_SCHEDULE__SOURCE_LINE_REFERENCE,
    first_value(AUG_PRODUCT_TERMS__APPLICABILITY_FUEL_TYPE) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_TERMS__APPLICABILITY_FUEL_TYPE,
    first_value(AUG_PRODUCT_TERMS__APPLICABILITY_VEHICLE_MAKE) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_TERMS__APPLICABILITY_VEHICLE_MAKE,
    first_value(AUG_PRODUCT_TERMS__APPLICABILITY_VEHICLE_MODEL) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_TERMS__APPLICABILITY_VEHICLE_MODEL,
    first_value(AUG_PRODUCT_TERMS__CEILING_KILOMETRE_READING) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_TERMS__CEILING_KILOMETRE_READING,
    first_value(AUG_PRODUCT_TERMS__CEILING_RUNNING_HOUR_READING) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_TERMS__CEILING_RUNNING_HOUR_READING,
    first_value(AUG_PRODUCT_TERMS__MAXIMUM_VEHICLE_AGE_DAYS) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_TERMS__MAXIMUM_VEHICLE_AGE_DAYS,
    first_value(AUG_PRODUCT_TERMS__MILEAGE_LIMIT) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_TERMS__MILEAGE_LIMIT,
    first_value(AUG_PRODUCT_TERMS__MINIMUM_VEHICLE_AGE_DAYS) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_TERMS__MINIMUM_VEHICLE_AGE_DAYS,
    first_value(AUG_PRODUCT_TERMS__PLAN_EFFECTIVE_FROM_DATE) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_TERMS__PLAN_EFFECTIVE_FROM_DATE,
    first_value(AUG_PRODUCT_TERMS__RUNNING_HOUR_LIMIT) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_TERMS__RUNNING_HOUR_LIMIT,
    first_value(AUG_PRODUCT_TERMS__WARRANTY_TERM) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_TERMS__WARRANTY_TERM,
    AUG_RISK_MOTOR_DRIVER__DRIVER_LICENCE_NUMBER_CK,
    AUG_RISK_MOTOR_DRIVER__DRIVER_ROLE_CK,
    first_value(AUG_RISK_MOTOR_DRIVER__AGE_AT_LICENCE_ISSUE) ignore nulls over (partition by RISK_OBJECT_BK, AUG_RISK_MOTOR_DRIVER__DRIVER_LICENCE_NUMBER_CK, AUG_RISK_MOTOR_DRIVER__DRIVER_ROLE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_DRIVER__AGE_AT_LICENCE_ISSUE,
    first_value(AUG_RISK_MOTOR_DRIVER__DRIVER_LINE_PARTICULARS) ignore nulls over (partition by RISK_OBJECT_BK, AUG_RISK_MOTOR_DRIVER__DRIVER_LICENCE_NUMBER_CK, AUG_RISK_MOTOR_DRIVER__DRIVER_ROLE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_DRIVER__DRIVER_LINE_PARTICULARS,
    first_value(COVERAGE_MOTOR_PA_OCCUPANT__NUMBER_OF_PERSONS_COVERED) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COVERAGE_MOTOR_PA_OCCUPANT__NUMBER_OF_PERSONS_COVERED,
    first_value(COVERAGE_MOTOR_PA_OCCUPANT__PAID_DRIVER_COUNT) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COVERAGE_MOTOR_PA_OCCUPANT__PAID_DRIVER_COUNT,
    POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
    POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK,
    first_value(POLICY_COVERAGE_SCHEDULE__COVERAGE_OPTED_INDICATOR) ignore nulls over (partition by POLICY_BK, POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_COVERAGE_SCHEDULE__COVERAGE_OPTED_INDICATOR,
    first_value(POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE) ignore nulls over (partition by POLICY_BK, POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE,
    first_value(POLICY_COVERAGE_SCHEDULE__PREMIUM_FOR_COVERAGE) ignore nulls over (partition by POLICY_BK, POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_COVERAGE_SCHEDULE__PREMIUM_FOR_COVERAGE,
    first_value(POLICY_COVERAGE_SCHEDULE__SUM_INSURED) ignore nulls over (partition by POLICY_BK, POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_COVERAGE_SCHEDULE__SUM_INSURED,
    first_value(POLICY_TERMS__DEDUCTIBLE_TOTAL) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TERMS__DEDUCTIBLE_TOTAL,
    first_value(POLICY_TERMS__GEOGRAPHICAL_SCOPE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TERMS__GEOGRAPHICAL_SCOPE,
    first_value(POLICY_TERMS__SPECIAL_CONDITIONS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TERMS__SPECIAL_CONDITIONS,
    first_value(POLICY_TERMS__WAITING_PERIOD) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TERMS__WAITING_PERIOD,
    first_value(PRODUCT_DEFINITION__PRODUCT_DESCRIPTION) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PRODUCT_DEFINITION__PRODUCT_DESCRIPTION,
    first_value(PRODUCT_DEFINITION__PRODUCT_NAME) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PRODUCT_DEFINITION__PRODUCT_NAME,
    first_value(PRODUCT_DEFINITION__PRODUCT_STATUS) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PRODUCT_DEFINITION__PRODUCT_STATUS,
    first_value(PRODUCT_DEFINITION__UIN) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PRODUCT_DEFINITION__UIN,
    -- the row's own source time: LOAD_DATETIME for hubs, links and single-active satellites
    m.INC_JOB_UPDATED_AT,
    -- SAT_AUG_COVERAGE_MOTOR_ADDON_PARAMS (ma_sat): one load time per COVERAGE_BK, so all its child rows share it
    max(case when coalesce(m.AUG_COVERAGE_MOTOR_ADDON_PARAMS__TYRE_DESCRIPTION, m.AUG_COVERAGE_MOTOR_ADDON_PARAMS__TYRE_DETAIL) is not null
             then m.INC_JOB_UPDATED_AT end)
        over (partition by m.COVERAGE_BK) as AUG_COVERAGE_MOTOR_ADDON_PARAMS__LOAD_DATETIME,
    -- SAT_AUG_POLICY_COVERAGE_SCHEDULE (ma_sat): one load time per POLICY_BK, so all its child rows share it
    max(case when coalesce(m.AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_RATE, m.AUG_POLICY_COVERAGE_SCHEDULE__SOURCE_LINE_REFERENCE) is not null
             then m.INC_JOB_UPDATED_AT end)
        over (partition by m.POLICY_BK) as AUG_POLICY_COVERAGE_SCHEDULE__LOAD_DATETIME,
    -- SAT_AUG_RISK_MOTOR_DRIVER (ma_sat): one load time per RISK_OBJECT_BK, so all its child rows share it
    max(case when coalesce(m.AUG_RISK_MOTOR_DRIVER__AGE_AT_LICENCE_ISSUE, m.AUG_RISK_MOTOR_DRIVER__DRIVER_LINE_PARTICULARS) is not null
             then m.INC_JOB_UPDATED_AT end)
        over (partition by m.RISK_OBJECT_BK) as AUG_RISK_MOTOR_DRIVER__LOAD_DATETIME,
    -- SAT_POLICY_COVERAGE_SCHEDULE (ma_sat): one load time per POLICY_BK, so all its child rows share it
    max(case when coalesce(m.POLICY_COVERAGE_SCHEDULE__COVERAGE_OPTED_INDICATOR, m.POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE, m.POLICY_COVERAGE_SCHEDULE__PREMIUM_FOR_COVERAGE, m.POLICY_COVERAGE_SCHEDULE__SUM_INSURED) is not null
             then m.INC_JOB_UPDATED_AT end)
        over (partition by m.POLICY_BK) as POLICY_COVERAGE_SCHEDULE__LOAD_DATETIME
from merged m
