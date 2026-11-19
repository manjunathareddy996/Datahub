-- CENTRAL VIEW v04_coverage -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   BJAZ_MOT_PKG_COVER_MST
--   BJAZ_MOT_PKG_MAPPED_COVERS
--   BJAZ_WAP_MOT_ADDONPKG
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_MOTOR_AUG_COVERAGE_CONDITIONS
--   SAT_MOTOR_AUG_COVERAGE_PACKAGE_RATING
--   SAT_COVERAGE_DEFINITION
--   SAT_COVERAGE_SUBLIMIT_SCHEDULE
-- Links whose legs come from one source row on this view (rule 6):
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: BJAZ_MOT_PKG_COVER_MST
    select
        nullif(nullif(trim(t0.cover_code), ''), '') as COVERAGE_BK,
        t0.veh_max_age as AUG_COVERAGE_CONDITIONS__MAXIMUM_VEHICLE_AGE,
        cast(null as varchar) as AUG_COVERAGE_PACKAGE_RATING__ADD_ON_PACKAGE_CODE_CK,
        cast(null as varchar) as AUG_COVERAGE_PACKAGE_RATING__PACKAGE_REFERENCE_CK,
        cast(null as varchar) as AUG_COVERAGE_PACKAGE_RATING__ADD_ON_PACKAGE_CODE,
        cast(null as varchar) as AUG_COVERAGE_PACKAGE_RATING__ADD_ON_PACKAGE_NAME,
        cast(null as varchar) as AUG_COVERAGE_PACKAGE_RATING__ADD_ON_PACKAGE_TYPE,
        cast(null as varchar) as AUG_COVERAGE_PACKAGE_RATING__MAXIMUM_BENEFIT_DAYS,
        cast(null as varchar) as AUG_COVERAGE_PACKAGE_RATING__PACKAGE_DISCOUNT_ENABLED_INDICATOR,
        cast(null as varchar) as AUG_COVERAGE_PACKAGE_RATING__PACKAGE_DISCOUNT_RATE,
        cast(null as varchar) as AUG_COVERAGE_PACKAGE_RATING__PACKAGE_ENTRY_FLAG,
        cast(null as varchar) as AUG_COVERAGE_PACKAGE_RATING__PACKAGE_LOADING_RATE,
        cast(null as varchar) as AUG_COVERAGE_PACKAGE_RATING__PACKAGE_SELECTED_INDICATOR,
        cast(null as varchar) as AUG_COVERAGE_PACKAGE_RATING__PACKAGE_SELECTION_STATUS,
        cast(null as varchar) as AUG_COVERAGE_PACKAGE_RATING__PACKAGE_SUM_INSURED,
        t0.cover_desc as COVERAGE_DEFINITION__COVERAGE_DESCRIPTION,
        t0.status as COVERAGE_DEFINITION__COVERAGE_STATUS,
        cast(null as varchar) as COVERAGE_SUBLIMIT_SCHEDULE__ACTIVE_SEQUENCE_NUMBER_CK,
        cast(null as varchar) as COVERAGE_SUBLIMIT_SCHEDULE__PER_DAY_LIMIT,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_pkg_cover_mst') }} t0
    where (nullif(nullif(trim(t0.cover_code), ''), '')) is not null

    union all

    -- branch 1: BJAZ_MOT_PKG_MAPPED_COVERS
    select
        nullif(nullif(trim(t0.cover_code), ''), '') as COVERAGE_BK,
        null, null,
        t0.package_id as AUG_COVERAGE_PACKAGE_RATING__PACKAGE_REFERENCE_CK,
        t0.package_id as AUG_COVERAGE_PACKAGE_RATING__ADD_ON_PACKAGE_CODE,
        null, null,
        t0.max_nodays_benefit as AUG_COVERAGE_PACKAGE_RATING__MAXIMUM_BENEFIT_DAYS,
        t0.enable_disc_yn as AUG_COVERAGE_PACKAGE_RATING__PACKAGE_DISCOUNT_ENABLED_INDICATOR,
        t0.discount_rate as AUG_COVERAGE_PACKAGE_RATING__PACKAGE_DISCOUNT_RATE,
        null,
        t0.loading_rate as AUG_COVERAGE_PACKAGE_RATING__PACKAGE_LOADING_RATE,
        null, null,
        t0.sum_insured as AUG_COVERAGE_PACKAGE_RATING__PACKAGE_SUM_INSURED,
        null, null, null,
        t0.per_days_benefit as COVERAGE_SUBLIMIT_SCHEDULE__PER_DAY_LIMIT,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_pkg_mapped_covers') }} t0
    where (nullif(nullif(trim(t0.cover_code), ''), '')) is not null

    union all

    -- branch 2: BJAZ_WAP_MOT_ADDONPKG
    select
        nullif(nullif(trim(t0.cover_code), ''), '') as COVERAGE_BK,
        null, null,
        t0.package_id as AUG_COVERAGE_PACKAGE_RATING__PACKAGE_REFERENCE_CK,
        t0.package_id as AUG_COVERAGE_PACKAGE_RATING__ADD_ON_PACKAGE_CODE,
        t0.package_name as AUG_COVERAGE_PACKAGE_RATING__ADD_ON_PACKAGE_NAME,
        t0.package_type as AUG_COVERAGE_PACKAGE_RATING__ADD_ON_PACKAGE_TYPE,
        null,
        t0.enable_disc_yn as AUG_COVERAGE_PACKAGE_RATING__PACKAGE_DISCOUNT_ENABLED_INDICATOR,
        t0.discount_rate as AUG_COVERAGE_PACKAGE_RATING__PACKAGE_DISCOUNT_RATE,
        t0.entry_flag as AUG_COVERAGE_PACKAGE_RATING__PACKAGE_ENTRY_FLAG,
        t0.loading_rate as AUG_COVERAGE_PACKAGE_RATING__PACKAGE_LOADING_RATE,
        t0.package_select_yn as AUG_COVERAGE_PACKAGE_RATING__PACKAGE_SELECTED_INDICATOR,
        t0.status as AUG_COVERAGE_PACKAGE_RATING__PACKAGE_SELECTION_STATUS,
        null,
        t0.cover_desc as COVERAGE_DEFINITION__COVERAGE_DESCRIPTION,
        null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_wap_mot_addonpkg') }} t0
    where (nullif(nullif(trim(t0.cover_code), ''), '')) is not null

)

select
    COVERAGE_BK,
    first_value(AUG_COVERAGE_CONDITIONS__MAXIMUM_VEHICLE_AGE) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_CONDITIONS__MAXIMUM_VEHICLE_AGE,
    AUG_COVERAGE_PACKAGE_RATING__ADD_ON_PACKAGE_CODE_CK,
    AUG_COVERAGE_PACKAGE_RATING__PACKAGE_REFERENCE_CK,
    first_value(AUG_COVERAGE_PACKAGE_RATING__ADD_ON_PACKAGE_CODE) ignore nulls over (partition by COVERAGE_BK, AUG_COVERAGE_PACKAGE_RATING__ADD_ON_PACKAGE_CODE_CK, AUG_COVERAGE_PACKAGE_RATING__PACKAGE_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_PACKAGE_RATING__ADD_ON_PACKAGE_CODE,
    first_value(AUG_COVERAGE_PACKAGE_RATING__ADD_ON_PACKAGE_NAME) ignore nulls over (partition by COVERAGE_BK, AUG_COVERAGE_PACKAGE_RATING__ADD_ON_PACKAGE_CODE_CK, AUG_COVERAGE_PACKAGE_RATING__PACKAGE_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_PACKAGE_RATING__ADD_ON_PACKAGE_NAME,
    first_value(AUG_COVERAGE_PACKAGE_RATING__ADD_ON_PACKAGE_TYPE) ignore nulls over (partition by COVERAGE_BK, AUG_COVERAGE_PACKAGE_RATING__ADD_ON_PACKAGE_CODE_CK, AUG_COVERAGE_PACKAGE_RATING__PACKAGE_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_PACKAGE_RATING__ADD_ON_PACKAGE_TYPE,
    first_value(AUG_COVERAGE_PACKAGE_RATING__MAXIMUM_BENEFIT_DAYS) ignore nulls over (partition by COVERAGE_BK, AUG_COVERAGE_PACKAGE_RATING__ADD_ON_PACKAGE_CODE_CK, AUG_COVERAGE_PACKAGE_RATING__PACKAGE_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_PACKAGE_RATING__MAXIMUM_BENEFIT_DAYS,
    first_value(AUG_COVERAGE_PACKAGE_RATING__PACKAGE_DISCOUNT_ENABLED_INDICATOR) ignore nulls over (partition by COVERAGE_BK, AUG_COVERAGE_PACKAGE_RATING__ADD_ON_PACKAGE_CODE_CK, AUG_COVERAGE_PACKAGE_RATING__PACKAGE_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_PACKAGE_RATING__PACKAGE_DISCOUNT_ENABLED_INDICATOR,
    first_value(AUG_COVERAGE_PACKAGE_RATING__PACKAGE_DISCOUNT_RATE) ignore nulls over (partition by COVERAGE_BK, AUG_COVERAGE_PACKAGE_RATING__ADD_ON_PACKAGE_CODE_CK, AUG_COVERAGE_PACKAGE_RATING__PACKAGE_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_PACKAGE_RATING__PACKAGE_DISCOUNT_RATE,
    first_value(AUG_COVERAGE_PACKAGE_RATING__PACKAGE_ENTRY_FLAG) ignore nulls over (partition by COVERAGE_BK, AUG_COVERAGE_PACKAGE_RATING__ADD_ON_PACKAGE_CODE_CK, AUG_COVERAGE_PACKAGE_RATING__PACKAGE_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_PACKAGE_RATING__PACKAGE_ENTRY_FLAG,
    first_value(AUG_COVERAGE_PACKAGE_RATING__PACKAGE_LOADING_RATE) ignore nulls over (partition by COVERAGE_BK, AUG_COVERAGE_PACKAGE_RATING__ADD_ON_PACKAGE_CODE_CK, AUG_COVERAGE_PACKAGE_RATING__PACKAGE_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_PACKAGE_RATING__PACKAGE_LOADING_RATE,
    first_value(AUG_COVERAGE_PACKAGE_RATING__PACKAGE_SELECTED_INDICATOR) ignore nulls over (partition by COVERAGE_BK, AUG_COVERAGE_PACKAGE_RATING__ADD_ON_PACKAGE_CODE_CK, AUG_COVERAGE_PACKAGE_RATING__PACKAGE_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_PACKAGE_RATING__PACKAGE_SELECTED_INDICATOR,
    first_value(AUG_COVERAGE_PACKAGE_RATING__PACKAGE_SELECTION_STATUS) ignore nulls over (partition by COVERAGE_BK, AUG_COVERAGE_PACKAGE_RATING__ADD_ON_PACKAGE_CODE_CK, AUG_COVERAGE_PACKAGE_RATING__PACKAGE_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_PACKAGE_RATING__PACKAGE_SELECTION_STATUS,
    first_value(AUG_COVERAGE_PACKAGE_RATING__PACKAGE_SUM_INSURED) ignore nulls over (partition by COVERAGE_BK, AUG_COVERAGE_PACKAGE_RATING__ADD_ON_PACKAGE_CODE_CK, AUG_COVERAGE_PACKAGE_RATING__PACKAGE_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_PACKAGE_RATING__PACKAGE_SUM_INSURED,
    first_value(COVERAGE_DEFINITION__COVERAGE_DESCRIPTION) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COVERAGE_DEFINITION__COVERAGE_DESCRIPTION,
    first_value(COVERAGE_DEFINITION__COVERAGE_STATUS) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COVERAGE_DEFINITION__COVERAGE_STATUS,
    COVERAGE_SUBLIMIT_SCHEDULE__ACTIVE_SEQUENCE_NUMBER_CK,
    first_value(COVERAGE_SUBLIMIT_SCHEDULE__PER_DAY_LIMIT) ignore nulls over (partition by COVERAGE_BK, COVERAGE_SUBLIMIT_SCHEDULE__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COVERAGE_SUBLIMIT_SCHEDULE__PER_DAY_LIMIT,
    -- the row's own source time: LOAD_DATETIME for hubs, links and single-active satellites
    m.INC_JOB_UPDATED_AT,
    -- multi-active satellites on COVERAGE_BK (SAT_MOTOR_AUG_COVERAGE_PACKAGE_RATING, SAT_COVERAGE_SUBLIMIT_SCHEDULE):
    -- one load time per COVERAGE_BK, the newest INC_JOB_UPDATED_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.AUG_COVERAGE_PACKAGE_RATING__ADD_ON_PACKAGE_CODE, m.AUG_COVERAGE_PACKAGE_RATING__ADD_ON_PACKAGE_NAME, m.AUG_COVERAGE_PACKAGE_RATING__ADD_ON_PACKAGE_TYPE, m.AUG_COVERAGE_PACKAGE_RATING__MAXIMUM_BENEFIT_DAYS, m.AUG_COVERAGE_PACKAGE_RATING__PACKAGE_DISCOUNT_ENABLED_INDICATOR, m.AUG_COVERAGE_PACKAGE_RATING__PACKAGE_DISCOUNT_RATE, m.AUG_COVERAGE_PACKAGE_RATING__PACKAGE_ENTRY_FLAG, m.AUG_COVERAGE_PACKAGE_RATING__PACKAGE_LOADING_RATE, m.AUG_COVERAGE_PACKAGE_RATING__PACKAGE_SELECTED_INDICATOR, m.AUG_COVERAGE_PACKAGE_RATING__PACKAGE_SELECTION_STATUS, m.AUG_COVERAGE_PACKAGE_RATING__PACKAGE_SUM_INSURED, m.COVERAGE_SUBLIMIT_SCHEDULE__PER_DAY_LIMIT) is not null
             then m.INC_JOB_UPDATED_AT end)
        over (partition by m.COVERAGE_BK) as COVERAGE_BK__MA_LOAD_DATETIME
from merged m
