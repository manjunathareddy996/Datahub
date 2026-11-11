-- CENTRAL VIEW v05_claim -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMTRANSITION_ATTRIBUTES_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PAYMENT_PAYMENT_CYCLE_PAYMENT_CYCLE_DETAILS_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_RESERVE_ATTRIBUTES_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_RESERVE_HISTORY_ATTRIBUTES_PIVOT_VW
-- Walk tables, joined only to resolve spine keys (not counted):
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMTRANSITION
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMTRANSITION_ATTRIBUTES
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PAYMENT
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PAYMENT_PAYMENT_CYCLE
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PAYMENT_PAYMENT_CYCLE_PAYMENT_CYCLE_DETAILS
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_RESERVE
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_RESERVE_ATTRIBUTES
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_RESERVE_HISTORY
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_RESERVE_HISTORY_ATTRIBUTES
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_CLAIM_STATUS_TRANSITION
--   SAT_CLAIM_PAYMENT_TRANCHE
--   SAT_CLAIM_RESERVE
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_CLAIM_COVERAGE
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMTRANSITION_ATTRIBUTES_PIVOT_VW
    select
        nullif(nullif(trim(j3.claim_number),''), '') as CLAIM_BK,
        cast(null as varchar) as COVERAGE_BK,
        cast(null as number) as __LNK_CLAIM_COVERAGE,
        t0.status as AUG_CLAIM_STATUS_TRANSITION__STATUS_CODE_CK,
        t0.date as AUG_CLAIM_STATUS_TRANSITION__TRANSITION_DATE_CK,
        t0.status as AUG_CLAIM_STATUS_TRANSITION__STATUS_CODE,
        t0.comments as AUG_CLAIM_STATUS_TRANSITION__TRANSITION_COMMENTS,
        t0.date as AUG_CLAIM_STATUS_TRANSITION__TRANSITION_DATE,
        t0.user_code as AUG_CLAIM_STATUS_TRANSITION__TRANSITION_PERFORMED_BY_REFERENCE,
        cast(null as varchar) as CLAIM_PAYMENT_TRANCHE__TRANCHE_NUMBER_CK,
        cast(null as varchar) as CLAIM_PAYMENT_TRANCHE__GROSS_AMOUNT,
        cast(null as varchar) as CLAIM_PAYMENT_TRANCHE__PAYMENT_TYPE,
        cast(null as varchar) as CLAIM_PAYMENT_TRANCHE__STATUS,
        cast(null as varchar) as CLAIM_RESERVE__RESERVE_HEAD_CK,
        cast(null as varchar) as CLAIM_RESERVE__CURRENT_RESERVE_AMOUNT,
        cast(null as varchar) as CLAIM_RESERVE__OUTSTANDING_RESERVE_AMOUNT,
        cast(null as varchar) as CLAIM_RESERVE__PAID_TO_DATE_AMOUNT,
        cast(null as varchar) as CLAIM_RESERVE__RESERVE_REVISION_DATE,
        cast(null as varchar) as CLAIM_RESERVE__RESERVE_REVISION_REASON,
        cast(null as varchar) as CLAIM_RESERVE__RESERVE_SET_BY_REFERENCE,
        cast(null as varchar) as CLAIM_RESERVE__RESERVE_STATUS,
        cast(null as varchar) as CLAIM_RESERVE__RESERVE_TYPE,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimtransition_attrs_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_claimtransition_attrs') }} j1 on j1.KEY_HASH = t0.FOREIGN_KEY
    left join {{ ref('stg_mxh__clm_cd_claimtransition') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.claim_number),''), '')) is not null

    union all

    -- branch 1: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PAYMENT_PAYMENT_CYCLE_PAYMENT_CYCLE_DETAILS_PIVOT_VW
    select
        nullif(nullif(trim(j4.claim_number),''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null,
        t0.invoice_number as CLAIM_PAYMENT_TRANCHE__TRANCHE_NUMBER_CK,
        t0.payment_amount as CLAIM_PAYMENT_TRANCHE__GROSS_AMOUNT,
        t0.purpose as CLAIM_PAYMENT_TRANCHE__PAYMENT_TYPE,
        t0.payment_status as CLAIM_PAYMENT_TRANCHE__STATUS,
        null, null, null, null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claim_payment_payment_cycle_payment_cycle_dtls_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_claim_payment_payment_cycle_payment_cycle_dtls') }} j1 on j1.KEY_HASH = t0.FOREIGN_KEY
    left join {{ ref('stg_mxh__clm_cd_claim_payment_payment_cycle') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_claim_payment') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.claim_number),''), '')) is not null

    union all

    -- branch 2: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_RESERVE_ATTRIBUTES_PIVOT_VW
    select
        nullif(nullif(trim(j3.claim_number),''), '') as CLAIM_BK,
        nullif('COV:' || nullif(trim(t0.impacted_cover_code),''), '') as COVERAGE_BK,
        1 as __LNK_CLAIM_COVERAGE,
        null, null, null, null, null, null, null, null, null, null,
        t0.type || '@' || t0.impacted_cover_code as CLAIM_RESERVE__RESERVE_HEAD_CK,
        t0.reserve_amount as CLAIM_RESERVE__CURRENT_RESERVE_AMOUNT,
        t0.pending_amount as CLAIM_RESERVE__OUTSTANDING_RESERVE_AMOUNT,
        t0.paid_amount as CLAIM_RESERVE__PAID_TO_DATE_AMOUNT,
        null, null, null, null,
        t0.type as CLAIM_RESERVE__RESERVE_TYPE,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claim_reserve_attrs_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_claim_reserve_attrs') }} j1 on j1.KEY_HASH = t0.FOREIGN_KEY
    left join {{ ref('stg_mxh__clm_cd_claim_reserve') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (coalesce(nullif('COV:' || nullif(trim(t0.impacted_cover_code),''), ''), nullif(nullif(trim(j3.claim_number),''), ''))) is not null

    union all

    -- branch 3: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_RESERVE_HISTORY_ATTRIBUTES_PIVOT_VW
    select
        nullif(nullif(trim(j3.claim_number),''), '') as CLAIM_BK,
        nullif('COV:' || nullif(trim(t0.impacted_cover_code),''), '') as COVERAGE_BK,
        1 as __LNK_CLAIM_COVERAGE,
        null, null, null, null, null, null, null, null, null, null,
        t0.type || '@' || t0.impacted_cover_code as CLAIM_RESERVE__RESERVE_HEAD_CK,
        t0.reserve_amount as CLAIM_RESERVE__CURRENT_RESERVE_AMOUNT,
        null, null,
        t0.reserve_date as CLAIM_RESERVE__RESERVE_REVISION_DATE,
        t0.reason as CLAIM_RESERVE__RESERVE_REVISION_REASON,
        t0.user_code as CLAIM_RESERVE__RESERVE_SET_BY_REFERENCE,
        t0.status as CLAIM_RESERVE__RESERVE_STATUS,
        t0.type as CLAIM_RESERVE__RESERVE_TYPE,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claim_reserve_history_attrs_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_claim_reserve_history_attrs') }} j1 on j1.KEY_HASH = t0.FOREIGN_KEY
    left join {{ ref('stg_mxh__clm_cd_claim_reserve_history') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (coalesce(nullif('COV:' || nullif(trim(t0.impacted_cover_code),''), ''), nullif(nullif(trim(j3.claim_number),''), ''))) is not null

)

select
    CLAIM_BK,
    COVERAGE_BK,
    __LNK_CLAIM_COVERAGE,
    AUG_CLAIM_STATUS_TRANSITION__STATUS_CODE_CK,
    AUG_CLAIM_STATUS_TRANSITION__TRANSITION_DATE_CK,
    first_value(AUG_CLAIM_STATUS_TRANSITION__STATUS_CODE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_STATUS_TRANSITION__STATUS_CODE_CK, AUG_CLAIM_STATUS_TRANSITION__TRANSITION_DATE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_STATUS_TRANSITION__STATUS_CODE,
    first_value(AUG_CLAIM_STATUS_TRANSITION__TRANSITION_COMMENTS) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_STATUS_TRANSITION__STATUS_CODE_CK, AUG_CLAIM_STATUS_TRANSITION__TRANSITION_DATE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_STATUS_TRANSITION__TRANSITION_COMMENTS,
    first_value(AUG_CLAIM_STATUS_TRANSITION__TRANSITION_DATE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_STATUS_TRANSITION__STATUS_CODE_CK, AUG_CLAIM_STATUS_TRANSITION__TRANSITION_DATE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_STATUS_TRANSITION__TRANSITION_DATE,
    first_value(AUG_CLAIM_STATUS_TRANSITION__TRANSITION_PERFORMED_BY_REFERENCE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_STATUS_TRANSITION__STATUS_CODE_CK, AUG_CLAIM_STATUS_TRANSITION__TRANSITION_DATE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_STATUS_TRANSITION__TRANSITION_PERFORMED_BY_REFERENCE,
    CLAIM_PAYMENT_TRANCHE__TRANCHE_NUMBER_CK,
    first_value(CLAIM_PAYMENT_TRANCHE__GROSS_AMOUNT) ignore nulls over (partition by CLAIM_BK, CLAIM_PAYMENT_TRANCHE__TRANCHE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_PAYMENT_TRANCHE__GROSS_AMOUNT,
    first_value(CLAIM_PAYMENT_TRANCHE__PAYMENT_TYPE) ignore nulls over (partition by CLAIM_BK, CLAIM_PAYMENT_TRANCHE__TRANCHE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_PAYMENT_TRANCHE__PAYMENT_TYPE,
    first_value(CLAIM_PAYMENT_TRANCHE__STATUS) ignore nulls over (partition by CLAIM_BK, CLAIM_PAYMENT_TRANCHE__TRANCHE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_PAYMENT_TRANCHE__STATUS,
    CLAIM_RESERVE__RESERVE_HEAD_CK,
    first_value(CLAIM_RESERVE__CURRENT_RESERVE_AMOUNT) ignore nulls over (partition by CLAIM_BK, CLAIM_RESERVE__RESERVE_HEAD_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_RESERVE__CURRENT_RESERVE_AMOUNT,
    first_value(CLAIM_RESERVE__OUTSTANDING_RESERVE_AMOUNT) ignore nulls over (partition by CLAIM_BK, CLAIM_RESERVE__RESERVE_HEAD_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_RESERVE__OUTSTANDING_RESERVE_AMOUNT,
    first_value(CLAIM_RESERVE__PAID_TO_DATE_AMOUNT) ignore nulls over (partition by CLAIM_BK, CLAIM_RESERVE__RESERVE_HEAD_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_RESERVE__PAID_TO_DATE_AMOUNT,
    first_value(CLAIM_RESERVE__RESERVE_REVISION_DATE) ignore nulls over (partition by CLAIM_BK, CLAIM_RESERVE__RESERVE_HEAD_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_RESERVE__RESERVE_REVISION_DATE,
    first_value(CLAIM_RESERVE__RESERVE_REVISION_REASON) ignore nulls over (partition by CLAIM_BK, CLAIM_RESERVE__RESERVE_HEAD_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_RESERVE__RESERVE_REVISION_REASON,
    first_value(CLAIM_RESERVE__RESERVE_SET_BY_REFERENCE) ignore nulls over (partition by CLAIM_BK, CLAIM_RESERVE__RESERVE_HEAD_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_RESERVE__RESERVE_SET_BY_REFERENCE,
    first_value(CLAIM_RESERVE__RESERVE_STATUS) ignore nulls over (partition by CLAIM_BK, CLAIM_RESERVE__RESERVE_HEAD_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_RESERVE__RESERVE_STATUS,
    first_value(CLAIM_RESERVE__RESERVE_TYPE) ignore nulls over (partition by CLAIM_BK, CLAIM_RESERVE__RESERVE_HEAD_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_RESERVE__RESERVE_TYPE
from merged
