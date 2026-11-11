-- CENTRAL VIEW v12_coverage -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BA_HCP_DT_PREMIUM (opus_health_legacy_v4)
--   BJAZ_GRP_TPA_EXTN (opus_health_legacy_v4)
--   BJAZ_STARPKG_COVER_MST (opus_health_delta3)
--   BJAZ_STARPKG_COV_PREM_MST (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_COVERAGE_DEFINITION
--   SAT_AUG_COVERAGE_PARAMETER
--   SAT_AUG_COVERAGE_PREMIUM_RATE_SLAB
--   SAT_COVERAGE_DEFINITION
--   SAT_POLICY_INSTALMENT_SCHEDULE
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_POLICY_COVERAGE
--   LNK_POLICY_PARTY
--   LNK_POLICY_PRODUCT
--   LNK_PRODUCT_COVERAGE
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: BA_HCP_DT_PREMIUM
    select
        hcp_seqno as COVERAGE_BK,
        user_id as PARTY_BK,
        contract_id as POLICY_BK,
        product_code as PRODUCT_BK,
        1 as __LNK_POLICY_COVERAGE,
        1 as __LNK_POLICY_PARTY,
        1 as __LNK_POLICY_PRODUCT,
        1 as __LNK_PRODUCT_COVERAGE,
        cast(null as varchar) as AUG_COVERAGE_DEFINITION__CATALOGUE_DISPLAY_ORDER,
        cast(null as varchar) as AUG_COVERAGE_DEFINITION__INDEPENDENTLY_SELECTABLE_INDICATOR,
        cast(null as varchar) as AUG_COVERAGE_DEFINITION__RATING_PARTICIPATION_INDICATOR,
        cast(null as varchar) as AUG_COVERAGE_DEFINITION__SECTION_REFERENCE,
        self_covered_flag as AUG_COVERAGE_DEFINITION__SELF_COVERED_INDICATOR,
        cast(null as varchar) as AUG_COVERAGE_PARAMETER__PARAMETER_REFERENCE,
        cast(null as varchar) as AUG_COVERAGE_PARAMETER__PARAMETER_VALUE,
        cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__AGE_LIMIT_BAND,
        cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__LINE_SEQUENCE_NUMBER,
        cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__PLAN_REFERENCE,
        cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__PREMIUM_APPLICABILITY_BASIS,
        cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__RATE_EFFECTIVE_DATE,
        cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__SECTION_REFERENCE,
        cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__SLAB_PREMIUM_RATE,
        cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__SUM_INSURED_SLAB_AMOUNT,
        cast(null as varchar) as COVERAGE_DEFINITION__COVERAGE_DESCRIPTION,
        inst_no as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER_CK,
        inst_date as POLICY_INSTALMENT_SCHEDULE__DUE_DATE,
        next_inst_amt as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_AMOUNT,
        inst_no as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER,
        inst_total_pending_amt as POLICY_INSTALMENT_SCHEDULE__OUTSTANDING_AFTER_INSTALMENT,
        inst_paid_amt as POLICY_INSTALMENT_SCHEDULE__PAID_AMOUNT,
        1000 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__ba_hcp_dt_premium') }}
    where (coalesce(contract_id, hcp_seqno, product_code, user_id)) is not null

    union all

    -- branch 1: BJAZ_GRP_TPA_EXTN
    select
        cast(null as varchar) as COVERAGE_BK,
        tpa_code as PARTY_BK,
        contract_id as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        cast(null as number) as __LNK_POLICY_COVERAGE,
        1 as __LNK_POLICY_PARTY,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_PRODUCT_COVERAGE,
        cast(null as varchar) as AUG_COVERAGE_DEFINITION__CATALOGUE_DISPLAY_ORDER,
        cast(null as varchar) as AUG_COVERAGE_DEFINITION__INDEPENDENTLY_SELECTABLE_INDICATOR,
        cast(null as varchar) as AUG_COVERAGE_DEFINITION__RATING_PARTICIPATION_INDICATOR,
        cast(null as varchar) as AUG_COVERAGE_DEFINITION__SECTION_REFERENCE,
        cast(null as varchar) as AUG_COVERAGE_DEFINITION__SELF_COVERED_INDICATOR,
        cast(null as varchar) as AUG_COVERAGE_PARAMETER__PARAMETER_REFERENCE,
        cast(null as varchar) as AUG_COVERAGE_PARAMETER__PARAMETER_VALUE,
        cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__AGE_LIMIT_BAND,
        cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__LINE_SEQUENCE_NUMBER,
        cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__PLAN_REFERENCE,
        cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__PREMIUM_APPLICABILITY_BASIS,
        cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__RATE_EFFECTIVE_DATE,
        cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__SECTION_REFERENCE,
        cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__SLAB_PREMIUM_RATE,
        cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__SUM_INSURED_SLAB_AMOUNT,
        cast(null as varchar) as COVERAGE_DEFINITION__COVERAGE_DESCRIPTION,
        cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER_CK,
        cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__DUE_DATE,
        cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_AMOUNT,
        cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER,
        cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__OUTSTANDING_AFTER_INSTALMENT,
        cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__PAID_AMOUNT,
        1001 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_grp_tpa_extn') }}
    where (coalesce(contract_id, tpa_code)) is not null

    union all

    -- branch 2: BJAZ_STARPKG_COVER_MST
    select
        nullif(trim(cover_code),'') as COVERAGE_BK,
        cast(null as varchar) as PARTY_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        cast(null as number) as __LNK_POLICY_COVERAGE,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_PRODUCT_COVERAGE,
        disp_order as AUG_COVERAGE_DEFINITION__CATALOGUE_DISPLAY_ORDER,
        checkbox_yn as AUG_COVERAGE_DEFINITION__INDEPENDENTLY_SELECTABLE_INDICATOR,
        rating_flag as AUG_COVERAGE_DEFINITION__RATING_PARTICIPATION_INDICATOR,
        section_id as AUG_COVERAGE_DEFINITION__SECTION_REFERENCE,
        cast(null as varchar) as AUG_COVERAGE_DEFINITION__SELF_COVERED_INDICATOR,
        cover_param as AUG_COVERAGE_PARAMETER__PARAMETER_REFERENCE,
        cover_value as AUG_COVERAGE_PARAMETER__PARAMETER_VALUE,
        cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__AGE_LIMIT_BAND,
        cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__LINE_SEQUENCE_NUMBER,
        cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__PLAN_REFERENCE,
        cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__PREMIUM_APPLICABILITY_BASIS,
        cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__RATE_EFFECTIVE_DATE,
        cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__SECTION_REFERENCE,
        cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__SLAB_PREMIUM_RATE,
        cast(null as varchar) as AUG_COVERAGE_PREMIUM_RATE_SLAB__SUM_INSURED_SLAB_AMOUNT,
        cover_desc as COVERAGE_DEFINITION__COVERAGE_DESCRIPTION,
        cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER_CK,
        cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__DUE_DATE,
        cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_AMOUNT,
        cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER,
        cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__OUTSTANDING_AFTER_INSTALMENT,
        cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__PAID_AMOUNT,
        2002 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_starpkg_cover_mst') }}
    where (nullif(trim(cover_code),'')) is not null

    union all

    -- branch 3: BJAZ_STARPKG_COV_PREM_MST
    select
        nullif(trim(cover_code),'') as COVERAGE_BK,
        cast(null as varchar) as PARTY_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        cast(null as number) as __LNK_POLICY_COVERAGE,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_PRODUCT_COVERAGE,
        cast(null as varchar) as AUG_COVERAGE_DEFINITION__CATALOGUE_DISPLAY_ORDER,
        cast(null as varchar) as AUG_COVERAGE_DEFINITION__INDEPENDENTLY_SELECTABLE_INDICATOR,
        cast(null as varchar) as AUG_COVERAGE_DEFINITION__RATING_PARTICIPATION_INDICATOR,
        cast(null as varchar) as AUG_COVERAGE_DEFINITION__SECTION_REFERENCE,
        cast(null as varchar) as AUG_COVERAGE_DEFINITION__SELF_COVERED_INDICATOR,
        cast(null as varchar) as AUG_COVERAGE_PARAMETER__PARAMETER_REFERENCE,
        cast(null as varchar) as AUG_COVERAGE_PARAMETER__PARAMETER_VALUE,
        age_limit as AUG_COVERAGE_PREMIUM_RATE_SLAB__AGE_LIMIT_BAND,
        sr_no as AUG_COVERAGE_PREMIUM_RATE_SLAB__LINE_SEQUENCE_NUMBER,
        plan_code as AUG_COVERAGE_PREMIUM_RATE_SLAB__PLAN_REFERENCE,
        prem_flag as AUG_COVERAGE_PREMIUM_RATE_SLAB__PREMIUM_APPLICABILITY_BASIS,
        eff_date as AUG_COVERAGE_PREMIUM_RATE_SLAB__RATE_EFFECTIVE_DATE,
        section_id as AUG_COVERAGE_PREMIUM_RATE_SLAB__SECTION_REFERENCE,
        premium as AUG_COVERAGE_PREMIUM_RATE_SLAB__SLAB_PREMIUM_RATE,
        total_si as AUG_COVERAGE_PREMIUM_RATE_SLAB__SUM_INSURED_SLAB_AMOUNT,
        cast(null as varchar) as COVERAGE_DEFINITION__COVERAGE_DESCRIPTION,
        cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER_CK,
        cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__DUE_DATE,
        cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_AMOUNT,
        cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER,
        cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__OUTSTANDING_AFTER_INSTALMENT,
        cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__PAID_AMOUNT,
        2003 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_starpkg_cov_prem_mst') }}
    where (nullif(trim(cover_code),'')) is not null

)

select
    COVERAGE_BK,
    PARTY_BK,
    POLICY_BK,
    PRODUCT_BK,
    __LNK_POLICY_COVERAGE,
    __LNK_POLICY_PARTY,
    __LNK_POLICY_PRODUCT,
    __LNK_PRODUCT_COVERAGE,
    first_value(AUG_COVERAGE_DEFINITION__CATALOGUE_DISPLAY_ORDER) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_DEFINITION__CATALOGUE_DISPLAY_ORDER,
    first_value(AUG_COVERAGE_DEFINITION__INDEPENDENTLY_SELECTABLE_INDICATOR) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_DEFINITION__INDEPENDENTLY_SELECTABLE_INDICATOR,
    first_value(AUG_COVERAGE_DEFINITION__RATING_PARTICIPATION_INDICATOR) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_DEFINITION__RATING_PARTICIPATION_INDICATOR,
    first_value(AUG_COVERAGE_DEFINITION__SECTION_REFERENCE) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_DEFINITION__SECTION_REFERENCE,
    first_value(AUG_COVERAGE_DEFINITION__SELF_COVERED_INDICATOR) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_DEFINITION__SELF_COVERED_INDICATOR,
    first_value(AUG_COVERAGE_PARAMETER__PARAMETER_REFERENCE) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_PARAMETER__PARAMETER_REFERENCE,
    first_value(AUG_COVERAGE_PARAMETER__PARAMETER_VALUE) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_PARAMETER__PARAMETER_VALUE,
    first_value(AUG_COVERAGE_PREMIUM_RATE_SLAB__AGE_LIMIT_BAND) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_PREMIUM_RATE_SLAB__AGE_LIMIT_BAND,
    first_value(AUG_COVERAGE_PREMIUM_RATE_SLAB__LINE_SEQUENCE_NUMBER) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_PREMIUM_RATE_SLAB__LINE_SEQUENCE_NUMBER,
    first_value(AUG_COVERAGE_PREMIUM_RATE_SLAB__PLAN_REFERENCE) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_PREMIUM_RATE_SLAB__PLAN_REFERENCE,
    first_value(AUG_COVERAGE_PREMIUM_RATE_SLAB__PREMIUM_APPLICABILITY_BASIS) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_PREMIUM_RATE_SLAB__PREMIUM_APPLICABILITY_BASIS,
    first_value(AUG_COVERAGE_PREMIUM_RATE_SLAB__RATE_EFFECTIVE_DATE) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_PREMIUM_RATE_SLAB__RATE_EFFECTIVE_DATE,
    first_value(AUG_COVERAGE_PREMIUM_RATE_SLAB__SECTION_REFERENCE) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_PREMIUM_RATE_SLAB__SECTION_REFERENCE,
    first_value(AUG_COVERAGE_PREMIUM_RATE_SLAB__SLAB_PREMIUM_RATE) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_PREMIUM_RATE_SLAB__SLAB_PREMIUM_RATE,
    first_value(AUG_COVERAGE_PREMIUM_RATE_SLAB__SUM_INSURED_SLAB_AMOUNT) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_PREMIUM_RATE_SLAB__SUM_INSURED_SLAB_AMOUNT,
    first_value(COVERAGE_DEFINITION__COVERAGE_DESCRIPTION) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COVERAGE_DEFINITION__COVERAGE_DESCRIPTION,
    POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER_CK,
    first_value(POLICY_INSTALMENT_SCHEDULE__DUE_DATE) ignore nulls over (partition by POLICY_BK, POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_INSTALMENT_SCHEDULE__DUE_DATE,
    first_value(POLICY_INSTALMENT_SCHEDULE__INSTALMENT_AMOUNT) ignore nulls over (partition by POLICY_BK, POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_AMOUNT,
    first_value(POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER) ignore nulls over (partition by POLICY_BK, POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER,
    first_value(POLICY_INSTALMENT_SCHEDULE__OUTSTANDING_AFTER_INSTALMENT) ignore nulls over (partition by POLICY_BK, POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_INSTALMENT_SCHEDULE__OUTSTANDING_AFTER_INSTALMENT,
    first_value(POLICY_INSTALMENT_SCHEDULE__PAID_AMOUNT) ignore nulls over (partition by POLICY_BK, POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_INSTALMENT_SCHEDULE__PAID_AMOUNT
from merged
