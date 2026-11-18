-- CENTRAL VIEW v20_product -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   BJAZ_MOT_COMM_CAPPPING_MASTER
--   BJAZ_MOT_GEN_RATE_MASTER
--   BJAZ_MOT_PKG_MST
--   BJAZ_MOT_TP_GST_APPLICABLE_PRD
--   BJAZ_WAP_MOT_STP_RATE_SUMM
--   BJAZ_WS_MOT_STP_RATE_SUMM
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_PRODUCT_COMMISSION_GRID
--   SAT_AUG_PRODUCT_RATING_FACTOR
--   SAT_AUG_PRODUCT_RIDER_CATALOGUE
--   SAT_AUG_PRODUCT_TAX_APPLICABILITY
--   SAT_PRODUCT_COMMISSION_GRID
--   SAT_PRODUCT_DISCOUNT_LOADING
--   SAT_PRODUCT_RATING_FACTOR
--   SAT_PRODUCT_RIDER_CATALOGUE
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_QUOTE_PRODUCT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: BJAZ_MOT_COMM_CAPPPING_MASTER
    select
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        cast(null as varchar) as QUOTE_BK,
        cast(null as number) as __LNK_QUOTE_PRODUCT,
        cast(null as varchar) as AUG_PRODUCT_COMMISSION_GRID__ACTIVE_SEQUENCE_NUMBER_CK,
        t0.imd_code as AUG_PRODUCT_COMMISSION_GRID__INTERMEDIARY_CODE_CK,
        t0.subimd_code as AUG_PRODUCT_COMMISSION_GRID__SUB_INTERMEDIARY_CODE_CK,
        t0.vehicle_type_code as AUG_PRODUCT_COMMISSION_GRID__VEHICLE_TYPE_CODE_CK,
        t0.vehicle_make_code as AUG_PRODUCT_COMMISSION_GRID__VEHICLE_MAKE_CODE_CK,
        t0.business_type as AUG_PRODUCT_COMMISSION_GRID__BUSINESS_TYPE_CODE_CK,
        t0.value_from as AUG_PRODUCT_COMMISSION_GRID__BAND_LOWER_BOUND_CK,
        t0.value_to as AUG_PRODUCT_COMMISSION_GRID__BAND_UPPER_BOUND_CK,
        t0.effective_date as AUG_PRODUCT_COMMISSION_GRID__GRID_EFFECTIVE_DATE_CK,
        t0.business_type as AUG_PRODUCT_COMMISSION_GRID__APPLICABLE_BUSINESS_TYPE,
        t0.vehicle_make_code as AUG_PRODUCT_COMMISSION_GRID__APPLICABLE_VEHICLE_MAKE_CODE,
        t0.vehicle_type_code as AUG_PRODUCT_COMMISSION_GRID__APPLICABLE_VEHICLE_TYPE_CODE,
        t0.benefit_po_cap as AUG_PRODUCT_COMMISSION_GRID__BENEFIT_PAYOUT_CAP_PERCENTAGE,
        t0.relaxation_cap as AUG_PRODUCT_COMMISSION_GRID__RELAXATION_CAP_PERCENTAGE,
        t0.status as AUG_PRODUCT_COMMISSION_GRID__RULE_STATUS,
        t0.value_from as AUG_PRODUCT_COMMISSION_GRID__VALUE_BAND_FROM,
        t0.value_to as AUG_PRODUCT_COMMISSION_GRID__VALUE_BAND_TO,
        cast(null as varchar) as AUG_PRODUCT_RATING_FACTOR__ACTIVE_SEQUENCE_NUMBER_CK,
        cast(null as varchar) as AUG_PRODUCT_RATING_FACTOR__RATING_FACTOR_CODE_CK,
        cast(null as varchar) as AUG_PRODUCT_RATING_FACTOR__APPLICABILITY_FUEL_TYPE,
        cast(null as varchar) as AUG_PRODUCT_RATING_FACTOR__APPLICABILITY_MAKE_CODE,
        cast(null as varchar) as AUG_PRODUCT_RATING_FACTOR__APPLICABILITY_MODEL_CODE,
        cast(null as varchar) as AUG_PRODUCT_RATING_FACTOR__APPLICABILITY_STATE_NAME,
        cast(null as varchar) as AUG_PRODUCT_RATING_FACTOR__APPLICABILITY_SUB_PRODUCT_CODE,
        cast(null as varchar) as AUG_PRODUCT_RATING_FACTOR__APPLICABILITY_VEHICLE_TYPE_CODE,
        cast(null as varchar) as AUG_PRODUCT_RATING_FACTOR__RATING_FACTOR_NOTE,
        cast(null as varchar) as AUG_PRODUCT_RIDER_CATALOGUE__ACTIVE_SEQUENCE_NUMBER_CK,
        cast(null as varchar) as AUG_PRODUCT_RIDER_CATALOGUE__RIDER_CODE_CK,
        cast(null as varchar) as AUG_PRODUCT_RIDER_CATALOGUE__EXPIRY_DATE,
        cast(null as varchar) as AUG_PRODUCT_RIDER_CATALOGUE__MAXIMUM_VEHICLE_AGE,
        cast(null as varchar) as AUG_PRODUCT_RIDER_CATALOGUE__MULTI_YEAR_ELIGIBLE_INDICATOR,
        cast(null as varchar) as AUG_PRODUCT_RIDER_CATALOGUE__NEW_BUSINESS_ELIGIBLE_INDICATOR,
        cast(null as varchar) as AUG_PRODUCT_RIDER_CATALOGUE__NO_CLAIM_BONUS_DISCOUNT_APPLICABLE_INDICATOR,
        cast(null as varchar) as AUG_PRODUCT_RIDER_CATALOGUE__OWN_RENEWAL_ELIGIBLE_INDICATOR,
        cast(null as varchar) as AUG_PRODUCT_RIDER_CATALOGUE__RIDER_STATUS,
        cast(null as varchar) as AUG_PRODUCT_RIDER_CATALOGUE__ROLLOVER_RENEWAL_ELIGIBLE_INDICATOR,
        cast(null as varchar) as AUG_PRODUCT_TAX_APPLICABILITY__VEHICLE_CATEGORY_CODE_CK,
        cast(null as varchar) as AUG_PRODUCT_TAX_APPLICABILITY__EFFECTIVE_DATE_CK,
        cast(null as varchar) as AUG_PRODUCT_TAX_APPLICABILITY__EFFECTIVE_DATE,
        cast(null as varchar) as AUG_PRODUCT_TAX_APPLICABILITY__THIRD_PARTY_GST_APPLICABLE_INDICATOR,
        cast(null as varchar) as AUG_PRODUCT_TAX_APPLICABILITY__VEHICLE_CATEGORY_CODE,
        cast(null as varchar) as PRODUCT_COMMISSION_GRID__ACTIVE_SEQUENCE_NUMBER_CK,
        t0.effective_date as PRODUCT_COMMISSION_GRID__EFFECTIVE_DATE,
        t0.maximum_cap as PRODUCT_COMMISSION_GRID__MAXIMUM_PAYABLE_PERCENTAGE,
        cast(null as varchar) as PRODUCT_DISCOUNT_LOADING__ACTIVE_SEQUENCE_NUMBER_CK,
        cast(null as varchar) as PRODUCT_DISCOUNT_LOADING__DISCOUNT_PERCENTAGE,
        cast(null as varchar) as PRODUCT_DISCOUNT_LOADING__RULE_CODE,
        cast(null as varchar) as PRODUCT_RATING_FACTOR__ACTIVE_SEQUENCE_NUMBER_CK,
        cast(null as varchar) as PRODUCT_RATING_FACTOR__BASE_TARIFF_RATE,
        cast(null as varchar) as PRODUCT_RATING_FACTOR__EFFECTIVE_DATE,
        cast(null as varchar) as PRODUCT_RATING_FACTOR__RATING_FACTOR_CODE,
        cast(null as varchar) as PRODUCT_RATING_FACTOR__VALUE_RANGE_FROM,
        cast(null as varchar) as PRODUCT_RATING_FACTOR__VALUE_RANGE_TO,
        cast(null as varchar) as PRODUCT_RIDER_CATALOGUE__ACTIVE_SEQUENCE_NUMBER_CK,
        cast(null as varchar) as PRODUCT_RIDER_CATALOGUE__EFFECTIVE_DATE,
        cast(null as varchar) as PRODUCT_RIDER_CATALOGUE__RIDER_CODE,
        cast(null as varchar) as PRODUCT_RIDER_CATALOGUE__RIDER_NAME,
        cast(null as varchar) as PRODUCT_RIDER_CATALOGUE__RIDER_TYPE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_comm_cappping_master') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 1: BJAZ_MOT_GEN_RATE_MASTER | child-key literal(s): AUG_PRODUCT_RATING_FACTOR.Rating Factor Code=VEHICLE_TYPE_CODE
    select
        nullif(nullif(trim(to_char(t0.product_4digit_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'VEHICLE_TYPE_CODE' as AUG_PRODUCT_RATING_FACTOR__RATING_FACTOR_CODE_CK,
        null, null, null, null, null,
        t0.vehicle_type_code as AUG_PRODUCT_RATING_FACTOR__APPLICABILITY_VEHICLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_gen_rate_master') }} t0
    where (nullif(nullif(trim(to_char(t0.product_4digit_code)), ''), '')) is not null

    union all

    -- branch 2: BJAZ_MOT_GEN_RATE_MASTER | child-key literal(s): AUG_PRODUCT_RATING_FACTOR.Rating Factor Code=NOTE
    select
        nullif(nullif(trim(to_char(t0.product_4digit_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NOTE' as AUG_PRODUCT_RATING_FACTOR__RATING_FACTOR_CODE_CK,
        null, null, null, null, null, null,
        t0.note as AUG_PRODUCT_RATING_FACTOR__RATING_FACTOR_NOTE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_gen_rate_master') }} t0
    where (nullif(nullif(trim(to_char(t0.product_4digit_code)), ''), '')) is not null

    union all

    -- branch 3: BJAZ_MOT_GEN_RATE_MASTER | child-key literal(s): AUG_PRODUCT_RATING_FACTOR.Rating Factor Code=FUEL_TYPE
    select
        nullif(nullif(trim(to_char(t0.product_4digit_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'FUEL_TYPE' as AUG_PRODUCT_RATING_FACTOR__RATING_FACTOR_CODE_CK,
        t0.fuel_type as AUG_PRODUCT_RATING_FACTOR__APPLICABILITY_FUEL_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_gen_rate_master') }} t0
    where (nullif(nullif(trim(to_char(t0.product_4digit_code)), ''), '')) is not null

    union all

    -- branch 4: BJAZ_MOT_GEN_RATE_MASTER | child-key literal(s): AUG_PRODUCT_RATING_FACTOR.Rating Factor Code=STATE_NAME
    select
        nullif(nullif(trim(to_char(t0.product_4digit_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'STATE_NAME' as AUG_PRODUCT_RATING_FACTOR__RATING_FACTOR_CODE_CK,
        null, null, null,
        t0.state_name as AUG_PRODUCT_RATING_FACTOR__APPLICABILITY_STATE_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_gen_rate_master') }} t0
    where (nullif(nullif(trim(to_char(t0.product_4digit_code)), ''), '')) is not null

    union all

    -- branch 5: BJAZ_MOT_GEN_RATE_MASTER | child-key literal(s): AUG_PRODUCT_RATING_FACTOR.Rating Factor Code=SUB_PRODUCT_CODE
    select
        nullif(nullif(trim(to_char(t0.product_4digit_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SUB_PRODUCT_CODE' as AUG_PRODUCT_RATING_FACTOR__RATING_FACTOR_CODE_CK,
        null, null, null, null,
        t0.sub_product_code as AUG_PRODUCT_RATING_FACTOR__APPLICABILITY_SUB_PRODUCT_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_gen_rate_master') }} t0
    where (nullif(nullif(trim(to_char(t0.product_4digit_code)), ''), '')) is not null

    union all

    -- branch 6: BJAZ_MOT_GEN_RATE_MASTER | child-key literal(s): AUG_PRODUCT_RATING_FACTOR.Rating Factor Code=MAKE_CODE
    select
        nullif(nullif(trim(to_char(t0.product_4digit_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'MAKE_CODE' as AUG_PRODUCT_RATING_FACTOR__RATING_FACTOR_CODE_CK,
        null,
        t0.make_code as AUG_PRODUCT_RATING_FACTOR__APPLICABILITY_MAKE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_gen_rate_master') }} t0
    where (nullif(nullif(trim(to_char(t0.product_4digit_code)), ''), '')) is not null

    union all

    -- branch 7: BJAZ_MOT_GEN_RATE_MASTER | child-key literal(s): AUG_PRODUCT_RATING_FACTOR.Rating Factor Code=MODEL_CODE
    select
        nullif(nullif(trim(to_char(t0.product_4digit_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'MODEL_CODE' as AUG_PRODUCT_RATING_FACTOR__RATING_FACTOR_CODE_CK,
        null, null,
        t0.model_code as AUG_PRODUCT_RATING_FACTOR__APPLICABILITY_MODEL_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_gen_rate_master') }} t0
    where (nullif(nullif(trim(to_char(t0.product_4digit_code)), ''), '')) is not null

    union all

    -- branch 8: BJAZ_MOT_GEN_RATE_MASTER
    select
        nullif(nullif(trim(to_char(t0.product_4digit_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        coalesce(t0.od_discount, t0.tp_discount) as PRODUCT_DISCOUNT_LOADING__DISCOUNT_PERCENTAGE,
        null, null,
        coalesce(t0.act_rate, t0.act_rate2, t0.act_rate3, t0.act_rate4, t0.act_rate5, t0.od_rate) as PRODUCT_RATING_FACTOR__BASE_TARIFF_RATE,
        t0.effective_date as PRODUCT_RATING_FACTOR__EFFECTIVE_DATE,
        t0.param_code as PRODUCT_RATING_FACTOR__RATING_FACTOR_CODE,
        coalesce(t0.act_min_value, t0.od_min_value) as PRODUCT_RATING_FACTOR__VALUE_RANGE_FROM,
        coalesce(t0.act_max_value, t0.od_max_value) as PRODUCT_RATING_FACTOR__VALUE_RANGE_TO,
        null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_gen_rate_master') }} t0
    where (nullif(nullif(trim(to_char(t0.product_4digit_code)), ''), '')) is not null

    union all

    -- branch 9: BJAZ_MOT_PKG_MST | child-key literal(s): AUG_PRODUCT_RIDER_CATALOGUE.Rider Code=EXPIRY_DATE
    select
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'EXPIRY_DATE' as AUG_PRODUCT_RIDER_CATALOGUE__RIDER_CODE_CK,
        t0.expiry_date as AUG_PRODUCT_RIDER_CATALOGUE__EXPIRY_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_pkg_mst') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 10: BJAZ_MOT_PKG_MST | child-key literal(s): AUG_PRODUCT_RIDER_CATALOGUE.Rider Code=MAX_VEH_AGE
    select
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'MAX_VEH_AGE' as AUG_PRODUCT_RIDER_CATALOGUE__RIDER_CODE_CK,
        null,
        t0.max_veh_age as AUG_PRODUCT_RIDER_CATALOGUE__MAXIMUM_VEHICLE_AGE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_pkg_mst') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 11: BJAZ_MOT_PKG_MST | child-key literal(s): AUG_PRODUCT_RIDER_CATALOGUE.Rider Code=STATUS
    select
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'STATUS' as AUG_PRODUCT_RIDER_CATALOGUE__RIDER_CODE_CK,
        null, null, null, null, null, null,
        t0.status as AUG_PRODUCT_RIDER_CATALOGUE__RIDER_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_pkg_mst') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 12: BJAZ_MOT_PKG_MST | child-key literal(s): AUG_PRODUCT_RIDER_CATALOGUE.Rider Code=MULTI_YR_YN
    select
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'MULTI_YR_YN' as AUG_PRODUCT_RIDER_CATALOGUE__RIDER_CODE_CK,
        null, null,
        t0.multi_yr_yn as AUG_PRODUCT_RIDER_CATALOGUE__MULTI_YEAR_ELIGIBLE_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_pkg_mst') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 13: BJAZ_MOT_PKG_MST | child-key literal(s): AUG_PRODUCT_RIDER_CATALOGUE.Rider Code=P_NB_YN
    select
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'P_NB_YN' as AUG_PRODUCT_RIDER_CATALOGUE__RIDER_CODE_CK,
        null, null, null,
        t0.p_nb_yn as AUG_PRODUCT_RIDER_CATALOGUE__NEW_BUSINESS_ELIGIBLE_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_pkg_mst') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 14: BJAZ_MOT_PKG_MST | child-key literal(s): AUG_PRODUCT_RIDER_CATALOGUE.Rider Code=P_OTRNW_YN
    select
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'P_OTRNW_YN' as AUG_PRODUCT_RIDER_CATALOGUE__RIDER_CODE_CK,
        null, null, null, null, null, null, null,
        t0.p_otrnw_yn as AUG_PRODUCT_RIDER_CATALOGUE__ROLLOVER_RENEWAL_ELIGIBLE_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_pkg_mst') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 15: BJAZ_MOT_PKG_MST | child-key literal(s): AUG_PRODUCT_RIDER_CATALOGUE.Rider Code=P_RNW_YN
    select
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'P_RNW_YN' as AUG_PRODUCT_RIDER_CATALOGUE__RIDER_CODE_CK,
        null, null, null, null, null,
        t0.p_rnw_yn as AUG_PRODUCT_RIDER_CATALOGUE__OWN_RENEWAL_ELIGIBLE_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_pkg_mst') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 16: BJAZ_MOT_PKG_MST | child-key literal(s): AUG_PRODUCT_RIDER_CATALOGUE.Rider Code=NCB_DISC_YN
    select
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'NCB_DISC_YN' as AUG_PRODUCT_RIDER_CATALOGUE__RIDER_CODE_CK,
        null, null, null, null,
        t0.ncb_disc_yn as AUG_PRODUCT_RIDER_CATALOGUE__NO_CLAIM_BONUS_DISCOUNT_APPLICABLE_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_pkg_mst') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 17: BJAZ_MOT_PKG_MST
    select
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        t0.effective_date as PRODUCT_RIDER_CATALOGUE__EFFECTIVE_DATE,
        t0.package_id as PRODUCT_RIDER_CATALOGUE__RIDER_CODE,
        t0.package_name as PRODUCT_RIDER_CATALOGUE__RIDER_NAME,
        t0.package_type as PRODUCT_RIDER_CATALOGUE__RIDER_TYPE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_pkg_mst') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 18: BJAZ_MOT_TP_GST_APPLICABLE_PRD
    select
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.effective_date as AUG_PRODUCT_TAX_APPLICABILITY__EFFECTIVE_DATE,
        t0.active_status as AUG_PRODUCT_TAX_APPLICABILITY__THIRD_PARTY_GST_APPLICABLE_INDICATOR,
        t0.vehicle_type_code as AUG_PRODUCT_TAX_APPLICABILITY__VEHICLE_CATEGORY_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_tp_gst_applicable_prd') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 19: BJAZ_WAP_MOT_STP_RATE_SUMM
    select
        nullif(nullif(trim(to_char(t0.prod_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.disc_perc as PRODUCT_DISCOUNT_LOADING__DISCOUNT_PERCENTAGE,
        t0.param_ref as PRODUCT_DISCOUNT_LOADING__RULE_CODE,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_wap_mot_stp_rate_summ') }} t0
    where (nullif(nullif(trim(to_char(t0.prod_code)), ''), '')) is not null

    union all

    -- branch 20: BJAZ_WS_MOT_STP_RATE_SUMM
    select
        nullif(nullif(trim(to_char(t0.prod_code)), ''), '') as PRODUCT_BK,
        nullif(nullif(trim(to_char(t0.transaction_id)), ''), '') as QUOTE_BK,
        1 as __LNK_QUOTE_PRODUCT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.disc_perc as PRODUCT_DISCOUNT_LOADING__DISCOUNT_PERCENTAGE,
        t0.param_ref as PRODUCT_DISCOUNT_LOADING__RULE_CODE,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_ws_mot_stp_rate_summ') }} t0
    where (coalesce(nullif(nullif(trim(to_char(t0.prod_code)), ''), ''), nullif(nullif(trim(to_char(t0.transaction_id)), ''), ''))) is not null

)

select
    PRODUCT_BK,
    QUOTE_BK,
    __LNK_QUOTE_PRODUCT,
    AUG_PRODUCT_COMMISSION_GRID__ACTIVE_SEQUENCE_NUMBER_CK,
    AUG_PRODUCT_COMMISSION_GRID__INTERMEDIARY_CODE_CK,
    AUG_PRODUCT_COMMISSION_GRID__SUB_INTERMEDIARY_CODE_CK,
    AUG_PRODUCT_COMMISSION_GRID__VEHICLE_TYPE_CODE_CK,
    AUG_PRODUCT_COMMISSION_GRID__VEHICLE_MAKE_CODE_CK,
    AUG_PRODUCT_COMMISSION_GRID__BUSINESS_TYPE_CODE_CK,
    AUG_PRODUCT_COMMISSION_GRID__BAND_LOWER_BOUND_CK,
    AUG_PRODUCT_COMMISSION_GRID__BAND_UPPER_BOUND_CK,
    AUG_PRODUCT_COMMISSION_GRID__GRID_EFFECTIVE_DATE_CK,
    first_value(AUG_PRODUCT_COMMISSION_GRID__APPLICABLE_BUSINESS_TYPE) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_COMMISSION_GRID__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_COMMISSION_GRID__INTERMEDIARY_CODE_CK, AUG_PRODUCT_COMMISSION_GRID__SUB_INTERMEDIARY_CODE_CK, AUG_PRODUCT_COMMISSION_GRID__VEHICLE_TYPE_CODE_CK, AUG_PRODUCT_COMMISSION_GRID__VEHICLE_MAKE_CODE_CK, AUG_PRODUCT_COMMISSION_GRID__BUSINESS_TYPE_CODE_CK, AUG_PRODUCT_COMMISSION_GRID__BAND_LOWER_BOUND_CK, AUG_PRODUCT_COMMISSION_GRID__BAND_UPPER_BOUND_CK, AUG_PRODUCT_COMMISSION_GRID__GRID_EFFECTIVE_DATE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_COMMISSION_GRID__APPLICABLE_BUSINESS_TYPE,
    first_value(AUG_PRODUCT_COMMISSION_GRID__APPLICABLE_VEHICLE_MAKE_CODE) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_COMMISSION_GRID__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_COMMISSION_GRID__INTERMEDIARY_CODE_CK, AUG_PRODUCT_COMMISSION_GRID__SUB_INTERMEDIARY_CODE_CK, AUG_PRODUCT_COMMISSION_GRID__VEHICLE_TYPE_CODE_CK, AUG_PRODUCT_COMMISSION_GRID__VEHICLE_MAKE_CODE_CK, AUG_PRODUCT_COMMISSION_GRID__BUSINESS_TYPE_CODE_CK, AUG_PRODUCT_COMMISSION_GRID__BAND_LOWER_BOUND_CK, AUG_PRODUCT_COMMISSION_GRID__BAND_UPPER_BOUND_CK, AUG_PRODUCT_COMMISSION_GRID__GRID_EFFECTIVE_DATE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_COMMISSION_GRID__APPLICABLE_VEHICLE_MAKE_CODE,
    first_value(AUG_PRODUCT_COMMISSION_GRID__APPLICABLE_VEHICLE_TYPE_CODE) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_COMMISSION_GRID__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_COMMISSION_GRID__INTERMEDIARY_CODE_CK, AUG_PRODUCT_COMMISSION_GRID__SUB_INTERMEDIARY_CODE_CK, AUG_PRODUCT_COMMISSION_GRID__VEHICLE_TYPE_CODE_CK, AUG_PRODUCT_COMMISSION_GRID__VEHICLE_MAKE_CODE_CK, AUG_PRODUCT_COMMISSION_GRID__BUSINESS_TYPE_CODE_CK, AUG_PRODUCT_COMMISSION_GRID__BAND_LOWER_BOUND_CK, AUG_PRODUCT_COMMISSION_GRID__BAND_UPPER_BOUND_CK, AUG_PRODUCT_COMMISSION_GRID__GRID_EFFECTIVE_DATE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_COMMISSION_GRID__APPLICABLE_VEHICLE_TYPE_CODE,
    first_value(AUG_PRODUCT_COMMISSION_GRID__BENEFIT_PAYOUT_CAP_PERCENTAGE) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_COMMISSION_GRID__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_COMMISSION_GRID__INTERMEDIARY_CODE_CK, AUG_PRODUCT_COMMISSION_GRID__SUB_INTERMEDIARY_CODE_CK, AUG_PRODUCT_COMMISSION_GRID__VEHICLE_TYPE_CODE_CK, AUG_PRODUCT_COMMISSION_GRID__VEHICLE_MAKE_CODE_CK, AUG_PRODUCT_COMMISSION_GRID__BUSINESS_TYPE_CODE_CK, AUG_PRODUCT_COMMISSION_GRID__BAND_LOWER_BOUND_CK, AUG_PRODUCT_COMMISSION_GRID__BAND_UPPER_BOUND_CK, AUG_PRODUCT_COMMISSION_GRID__GRID_EFFECTIVE_DATE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_COMMISSION_GRID__BENEFIT_PAYOUT_CAP_PERCENTAGE,
    first_value(AUG_PRODUCT_COMMISSION_GRID__RELAXATION_CAP_PERCENTAGE) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_COMMISSION_GRID__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_COMMISSION_GRID__INTERMEDIARY_CODE_CK, AUG_PRODUCT_COMMISSION_GRID__SUB_INTERMEDIARY_CODE_CK, AUG_PRODUCT_COMMISSION_GRID__VEHICLE_TYPE_CODE_CK, AUG_PRODUCT_COMMISSION_GRID__VEHICLE_MAKE_CODE_CK, AUG_PRODUCT_COMMISSION_GRID__BUSINESS_TYPE_CODE_CK, AUG_PRODUCT_COMMISSION_GRID__BAND_LOWER_BOUND_CK, AUG_PRODUCT_COMMISSION_GRID__BAND_UPPER_BOUND_CK, AUG_PRODUCT_COMMISSION_GRID__GRID_EFFECTIVE_DATE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_COMMISSION_GRID__RELAXATION_CAP_PERCENTAGE,
    first_value(AUG_PRODUCT_COMMISSION_GRID__RULE_STATUS) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_COMMISSION_GRID__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_COMMISSION_GRID__INTERMEDIARY_CODE_CK, AUG_PRODUCT_COMMISSION_GRID__SUB_INTERMEDIARY_CODE_CK, AUG_PRODUCT_COMMISSION_GRID__VEHICLE_TYPE_CODE_CK, AUG_PRODUCT_COMMISSION_GRID__VEHICLE_MAKE_CODE_CK, AUG_PRODUCT_COMMISSION_GRID__BUSINESS_TYPE_CODE_CK, AUG_PRODUCT_COMMISSION_GRID__BAND_LOWER_BOUND_CK, AUG_PRODUCT_COMMISSION_GRID__BAND_UPPER_BOUND_CK, AUG_PRODUCT_COMMISSION_GRID__GRID_EFFECTIVE_DATE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_COMMISSION_GRID__RULE_STATUS,
    first_value(AUG_PRODUCT_COMMISSION_GRID__VALUE_BAND_FROM) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_COMMISSION_GRID__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_COMMISSION_GRID__INTERMEDIARY_CODE_CK, AUG_PRODUCT_COMMISSION_GRID__SUB_INTERMEDIARY_CODE_CK, AUG_PRODUCT_COMMISSION_GRID__VEHICLE_TYPE_CODE_CK, AUG_PRODUCT_COMMISSION_GRID__VEHICLE_MAKE_CODE_CK, AUG_PRODUCT_COMMISSION_GRID__BUSINESS_TYPE_CODE_CK, AUG_PRODUCT_COMMISSION_GRID__BAND_LOWER_BOUND_CK, AUG_PRODUCT_COMMISSION_GRID__BAND_UPPER_BOUND_CK, AUG_PRODUCT_COMMISSION_GRID__GRID_EFFECTIVE_DATE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_COMMISSION_GRID__VALUE_BAND_FROM,
    first_value(AUG_PRODUCT_COMMISSION_GRID__VALUE_BAND_TO) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_COMMISSION_GRID__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_COMMISSION_GRID__INTERMEDIARY_CODE_CK, AUG_PRODUCT_COMMISSION_GRID__SUB_INTERMEDIARY_CODE_CK, AUG_PRODUCT_COMMISSION_GRID__VEHICLE_TYPE_CODE_CK, AUG_PRODUCT_COMMISSION_GRID__VEHICLE_MAKE_CODE_CK, AUG_PRODUCT_COMMISSION_GRID__BUSINESS_TYPE_CODE_CK, AUG_PRODUCT_COMMISSION_GRID__BAND_LOWER_BOUND_CK, AUG_PRODUCT_COMMISSION_GRID__BAND_UPPER_BOUND_CK, AUG_PRODUCT_COMMISSION_GRID__GRID_EFFECTIVE_DATE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_COMMISSION_GRID__VALUE_BAND_TO,
    AUG_PRODUCT_RATING_FACTOR__ACTIVE_SEQUENCE_NUMBER_CK,
    AUG_PRODUCT_RATING_FACTOR__RATING_FACTOR_CODE_CK,
    first_value(AUG_PRODUCT_RATING_FACTOR__APPLICABILITY_FUEL_TYPE) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_RATING_FACTOR__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_RATING_FACTOR__RATING_FACTOR_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_RATING_FACTOR__APPLICABILITY_FUEL_TYPE,
    first_value(AUG_PRODUCT_RATING_FACTOR__APPLICABILITY_MAKE_CODE) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_RATING_FACTOR__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_RATING_FACTOR__RATING_FACTOR_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_RATING_FACTOR__APPLICABILITY_MAKE_CODE,
    first_value(AUG_PRODUCT_RATING_FACTOR__APPLICABILITY_MODEL_CODE) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_RATING_FACTOR__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_RATING_FACTOR__RATING_FACTOR_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_RATING_FACTOR__APPLICABILITY_MODEL_CODE,
    first_value(AUG_PRODUCT_RATING_FACTOR__APPLICABILITY_STATE_NAME) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_RATING_FACTOR__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_RATING_FACTOR__RATING_FACTOR_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_RATING_FACTOR__APPLICABILITY_STATE_NAME,
    first_value(AUG_PRODUCT_RATING_FACTOR__APPLICABILITY_SUB_PRODUCT_CODE) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_RATING_FACTOR__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_RATING_FACTOR__RATING_FACTOR_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_RATING_FACTOR__APPLICABILITY_SUB_PRODUCT_CODE,
    first_value(AUG_PRODUCT_RATING_FACTOR__APPLICABILITY_VEHICLE_TYPE_CODE) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_RATING_FACTOR__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_RATING_FACTOR__RATING_FACTOR_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_RATING_FACTOR__APPLICABILITY_VEHICLE_TYPE_CODE,
    first_value(AUG_PRODUCT_RATING_FACTOR__RATING_FACTOR_NOTE) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_RATING_FACTOR__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_RATING_FACTOR__RATING_FACTOR_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_RATING_FACTOR__RATING_FACTOR_NOTE,
    AUG_PRODUCT_RIDER_CATALOGUE__ACTIVE_SEQUENCE_NUMBER_CK,
    AUG_PRODUCT_RIDER_CATALOGUE__RIDER_CODE_CK,
    first_value(AUG_PRODUCT_RIDER_CATALOGUE__EXPIRY_DATE) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_RIDER_CATALOGUE__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_RIDER_CATALOGUE__RIDER_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_RIDER_CATALOGUE__EXPIRY_DATE,
    first_value(AUG_PRODUCT_RIDER_CATALOGUE__MAXIMUM_VEHICLE_AGE) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_RIDER_CATALOGUE__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_RIDER_CATALOGUE__RIDER_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_RIDER_CATALOGUE__MAXIMUM_VEHICLE_AGE,
    first_value(AUG_PRODUCT_RIDER_CATALOGUE__MULTI_YEAR_ELIGIBLE_INDICATOR) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_RIDER_CATALOGUE__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_RIDER_CATALOGUE__RIDER_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_RIDER_CATALOGUE__MULTI_YEAR_ELIGIBLE_INDICATOR,
    first_value(AUG_PRODUCT_RIDER_CATALOGUE__NEW_BUSINESS_ELIGIBLE_INDICATOR) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_RIDER_CATALOGUE__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_RIDER_CATALOGUE__RIDER_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_RIDER_CATALOGUE__NEW_BUSINESS_ELIGIBLE_INDICATOR,
    first_value(AUG_PRODUCT_RIDER_CATALOGUE__NO_CLAIM_BONUS_DISCOUNT_APPLICABLE_INDICATOR) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_RIDER_CATALOGUE__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_RIDER_CATALOGUE__RIDER_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_RIDER_CATALOGUE__NO_CLAIM_BONUS_DISCOUNT_APPLICABLE_INDICATOR,
    first_value(AUG_PRODUCT_RIDER_CATALOGUE__OWN_RENEWAL_ELIGIBLE_INDICATOR) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_RIDER_CATALOGUE__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_RIDER_CATALOGUE__RIDER_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_RIDER_CATALOGUE__OWN_RENEWAL_ELIGIBLE_INDICATOR,
    first_value(AUG_PRODUCT_RIDER_CATALOGUE__RIDER_STATUS) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_RIDER_CATALOGUE__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_RIDER_CATALOGUE__RIDER_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_RIDER_CATALOGUE__RIDER_STATUS,
    first_value(AUG_PRODUCT_RIDER_CATALOGUE__ROLLOVER_RENEWAL_ELIGIBLE_INDICATOR) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_RIDER_CATALOGUE__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_RIDER_CATALOGUE__RIDER_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_RIDER_CATALOGUE__ROLLOVER_RENEWAL_ELIGIBLE_INDICATOR,
    AUG_PRODUCT_TAX_APPLICABILITY__VEHICLE_CATEGORY_CODE_CK,
    AUG_PRODUCT_TAX_APPLICABILITY__EFFECTIVE_DATE_CK,
    first_value(AUG_PRODUCT_TAX_APPLICABILITY__EFFECTIVE_DATE) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_TAX_APPLICABILITY__VEHICLE_CATEGORY_CODE_CK, AUG_PRODUCT_TAX_APPLICABILITY__EFFECTIVE_DATE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_TAX_APPLICABILITY__EFFECTIVE_DATE,
    first_value(AUG_PRODUCT_TAX_APPLICABILITY__THIRD_PARTY_GST_APPLICABLE_INDICATOR) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_TAX_APPLICABILITY__VEHICLE_CATEGORY_CODE_CK, AUG_PRODUCT_TAX_APPLICABILITY__EFFECTIVE_DATE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_TAX_APPLICABILITY__THIRD_PARTY_GST_APPLICABLE_INDICATOR,
    first_value(AUG_PRODUCT_TAX_APPLICABILITY__VEHICLE_CATEGORY_CODE) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_TAX_APPLICABILITY__VEHICLE_CATEGORY_CODE_CK, AUG_PRODUCT_TAX_APPLICABILITY__EFFECTIVE_DATE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_TAX_APPLICABILITY__VEHICLE_CATEGORY_CODE,
    PRODUCT_COMMISSION_GRID__ACTIVE_SEQUENCE_NUMBER_CK,
    first_value(PRODUCT_COMMISSION_GRID__EFFECTIVE_DATE) ignore nulls over (partition by PRODUCT_BK, PRODUCT_COMMISSION_GRID__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PRODUCT_COMMISSION_GRID__EFFECTIVE_DATE,
    first_value(PRODUCT_COMMISSION_GRID__MAXIMUM_PAYABLE_PERCENTAGE) ignore nulls over (partition by PRODUCT_BK, PRODUCT_COMMISSION_GRID__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PRODUCT_COMMISSION_GRID__MAXIMUM_PAYABLE_PERCENTAGE,
    PRODUCT_DISCOUNT_LOADING__ACTIVE_SEQUENCE_NUMBER_CK,
    first_value(PRODUCT_DISCOUNT_LOADING__DISCOUNT_PERCENTAGE) ignore nulls over (partition by PRODUCT_BK, PRODUCT_DISCOUNT_LOADING__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PRODUCT_DISCOUNT_LOADING__DISCOUNT_PERCENTAGE,
    first_value(PRODUCT_DISCOUNT_LOADING__RULE_CODE) ignore nulls over (partition by PRODUCT_BK, PRODUCT_DISCOUNT_LOADING__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PRODUCT_DISCOUNT_LOADING__RULE_CODE,
    PRODUCT_RATING_FACTOR__ACTIVE_SEQUENCE_NUMBER_CK,
    first_value(PRODUCT_RATING_FACTOR__BASE_TARIFF_RATE) ignore nulls over (partition by PRODUCT_BK, PRODUCT_RATING_FACTOR__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PRODUCT_RATING_FACTOR__BASE_TARIFF_RATE,
    first_value(PRODUCT_RATING_FACTOR__EFFECTIVE_DATE) ignore nulls over (partition by PRODUCT_BK, PRODUCT_RATING_FACTOR__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PRODUCT_RATING_FACTOR__EFFECTIVE_DATE,
    first_value(PRODUCT_RATING_FACTOR__RATING_FACTOR_CODE) ignore nulls over (partition by PRODUCT_BK, PRODUCT_RATING_FACTOR__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PRODUCT_RATING_FACTOR__RATING_FACTOR_CODE,
    first_value(PRODUCT_RATING_FACTOR__VALUE_RANGE_FROM) ignore nulls over (partition by PRODUCT_BK, PRODUCT_RATING_FACTOR__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PRODUCT_RATING_FACTOR__VALUE_RANGE_FROM,
    first_value(PRODUCT_RATING_FACTOR__VALUE_RANGE_TO) ignore nulls over (partition by PRODUCT_BK, PRODUCT_RATING_FACTOR__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PRODUCT_RATING_FACTOR__VALUE_RANGE_TO,
    PRODUCT_RIDER_CATALOGUE__ACTIVE_SEQUENCE_NUMBER_CK,
    first_value(PRODUCT_RIDER_CATALOGUE__EFFECTIVE_DATE) ignore nulls over (partition by PRODUCT_BK, PRODUCT_RIDER_CATALOGUE__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PRODUCT_RIDER_CATALOGUE__EFFECTIVE_DATE,
    first_value(PRODUCT_RIDER_CATALOGUE__RIDER_CODE) ignore nulls over (partition by PRODUCT_BK, PRODUCT_RIDER_CATALOGUE__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PRODUCT_RIDER_CATALOGUE__RIDER_CODE,
    first_value(PRODUCT_RIDER_CATALOGUE__RIDER_NAME) ignore nulls over (partition by PRODUCT_BK, PRODUCT_RIDER_CATALOGUE__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PRODUCT_RIDER_CATALOGUE__RIDER_NAME,
    first_value(PRODUCT_RIDER_CATALOGUE__RIDER_TYPE) ignore nulls over (partition by PRODUCT_BK, PRODUCT_RIDER_CATALOGUE__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PRODUCT_RIDER_CATALOGUE__RIDER_TYPE,
    -- the row's own source time: LOAD_DATETIME for hubs, links and single-active satellites
    m.INC_JOB_UPDATED_AT,
    -- multi-active satellites on PRODUCT_BK (SAT_AUG_PRODUCT_COMMISSION_GRID, SAT_AUG_PRODUCT_RATING_FACTOR, SAT_AUG_PRODUCT_RIDER_CATALOGUE, SAT_AUG_PRODUCT_TAX_APPLICABILITY, SAT_PRODUCT_COMMISSION_GRID, SAT_PRODUCT_DISCOUNT_LOADING, SAT_PRODUCT_RATING_FACTOR, SAT_PRODUCT_RIDER_CATALOGUE):
    -- one load time per PRODUCT_BK, the newest INC_JOB_UPDATED_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.AUG_PRODUCT_COMMISSION_GRID__APPLICABLE_BUSINESS_TYPE, m.AUG_PRODUCT_COMMISSION_GRID__APPLICABLE_VEHICLE_MAKE_CODE, m.AUG_PRODUCT_COMMISSION_GRID__APPLICABLE_VEHICLE_TYPE_CODE, m.AUG_PRODUCT_COMMISSION_GRID__BENEFIT_PAYOUT_CAP_PERCENTAGE, m.AUG_PRODUCT_COMMISSION_GRID__RELAXATION_CAP_PERCENTAGE, m.AUG_PRODUCT_COMMISSION_GRID__RULE_STATUS, m.AUG_PRODUCT_COMMISSION_GRID__VALUE_BAND_FROM, m.AUG_PRODUCT_COMMISSION_GRID__VALUE_BAND_TO, m.AUG_PRODUCT_RATING_FACTOR__APPLICABILITY_FUEL_TYPE, m.AUG_PRODUCT_RATING_FACTOR__APPLICABILITY_MAKE_CODE, m.AUG_PRODUCT_RATING_FACTOR__APPLICABILITY_MODEL_CODE, m.AUG_PRODUCT_RATING_FACTOR__APPLICABILITY_STATE_NAME, m.AUG_PRODUCT_RATING_FACTOR__APPLICABILITY_SUB_PRODUCT_CODE, m.AUG_PRODUCT_RATING_FACTOR__APPLICABILITY_VEHICLE_TYPE_CODE, m.AUG_PRODUCT_RATING_FACTOR__RATING_FACTOR_NOTE, m.AUG_PRODUCT_RIDER_CATALOGUE__EXPIRY_DATE, m.AUG_PRODUCT_RIDER_CATALOGUE__MAXIMUM_VEHICLE_AGE, m.AUG_PRODUCT_RIDER_CATALOGUE__MULTI_YEAR_ELIGIBLE_INDICATOR, m.AUG_PRODUCT_RIDER_CATALOGUE__NEW_BUSINESS_ELIGIBLE_INDICATOR, m.AUG_PRODUCT_RIDER_CATALOGUE__NO_CLAIM_BONUS_DISCOUNT_APPLICABLE_INDICATOR, m.AUG_PRODUCT_RIDER_CATALOGUE__OWN_RENEWAL_ELIGIBLE_INDICATOR, m.AUG_PRODUCT_RIDER_CATALOGUE__RIDER_STATUS, m.AUG_PRODUCT_RIDER_CATALOGUE__ROLLOVER_RENEWAL_ELIGIBLE_INDICATOR, m.AUG_PRODUCT_TAX_APPLICABILITY__EFFECTIVE_DATE, m.AUG_PRODUCT_TAX_APPLICABILITY__THIRD_PARTY_GST_APPLICABLE_INDICATOR, m.AUG_PRODUCT_TAX_APPLICABILITY__VEHICLE_CATEGORY_CODE, m.PRODUCT_COMMISSION_GRID__EFFECTIVE_DATE, m.PRODUCT_COMMISSION_GRID__MAXIMUM_PAYABLE_PERCENTAGE, m.PRODUCT_DISCOUNT_LOADING__DISCOUNT_PERCENTAGE, m.PRODUCT_DISCOUNT_LOADING__RULE_CODE, m.PRODUCT_RATING_FACTOR__BASE_TARIFF_RATE, m.PRODUCT_RATING_FACTOR__EFFECTIVE_DATE, m.PRODUCT_RATING_FACTOR__RATING_FACTOR_CODE, m.PRODUCT_RATING_FACTOR__VALUE_RANGE_FROM, m.PRODUCT_RATING_FACTOR__VALUE_RANGE_TO, m.PRODUCT_RIDER_CATALOGUE__EFFECTIVE_DATE, m.PRODUCT_RIDER_CATALOGUE__RIDER_CODE, m.PRODUCT_RIDER_CATALOGUE__RIDER_NAME, m.PRODUCT_RIDER_CATALOGUE__RIDER_TYPE) is not null
             then m.INC_JOB_UPDATED_AT end)
        over (partition by m.PRODUCT_BK) as PRODUCT_BK__MA_LOAD_DATETIME
from merged m
