-- CENTRAL VIEW v09_financial_transaction -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_LIST_OF_COVERS_COVER_SET_ATTRIBUTE_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_MEMBER_DETAILS_TAB_GRADED_SI_DETAILS
--   MAXI_HLTH_UWR_VW_DATA_MEMBER_RIDER_DETAILS
--   MAXI_HLTH_UWR_VW_DATA_PREMIUM_CALCULATION_DETAILS
--   MAXI_HLTH_UWR_VW_DATA_RECEIPT_DETAILS_LIST
--   MAXI_HLTH_UWR_VW_DATA_VIEW_COLLECTIONS
-- Walk tables, joined only to resolve spine keys (not counted):
--   MAXI_HLTH_UWR_VW_DATA
--   MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS
--   MAXI_HLTH_UWR_VW_DATA_MEMBER_DETAILS_TAB
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_COMMON_MONETARY_CONTEXT
--   SAT_COVERAGE_DEFINITION
--   SAT_FIN_RECEIPT
--   SAT_POLICY_BONUS_TRACKING
-- Links whose legs come from one source row on this view (rule 6):
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_LIST_OF_COVERS_COVER_SET_ATTRIBUTE_PIVOT_VW
    select
        nullif('COV:' || nullif(trim(t0.cover),''), '') as COVERAGE_BK,
        cast(null as varchar) as FINANCIAL_TRANSACTION_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as varchar) as COMMON_MONETARY_CONTEXT__BASE_CURRENCY_CODE,
        cast(null as varchar) as COMMON_MONETARY_CONTEXT__CURRENCY_CODE,
        cast(null as varchar) as COMMON_MONETARY_CONTEXT__EXCHANGE_RATE,
        cast(null as varchar) as COVERAGE_DEFINITION__COVERAGE_CODE,
        cast(null as varchar) as COVERAGE_DEFINITION__COVERAGE_DESCRIPTION,
        cast(null as varchar) as COVERAGE_DEFINITION__COVERAGE_DISPLAY_NAME,
        cast(null as varchar) as COVERAGE_DEFINITION__COVERAGE_GROUP,
        t0.cover_name as COVERAGE_DEFINITION__COVERAGE_NAME,
        cast(null as varchar) as COVERAGE_DEFINITION__COVERAGE_TYPE,
        cast(null as varchar) as COVERAGE_DEFINITION__MANDATORY_INDICATOR,
        cast(null as varchar) as FIN_RECEIPT__AMOUNT_RECEIVED,
        cast(null as varchar) as FIN_RECEIPT__INSTRUMENT_DATE,
        cast(null as varchar) as FIN_RECEIPT__INSTRUMENT_REFERENCE,
        cast(null as varchar) as FIN_RECEIPT__INSTRUMENT_TYPE,
        cast(null as varchar) as FIN_RECEIPT__PAYER_NAME,
        cast(null as varchar) as FIN_RECEIPT__REALISATION_STATUS,
        cast(null as varchar) as FIN_RECEIPT__RECEIPT_DATE,
        cast(null as varchar) as FIN_RECEIPT__RECEIPT_NUMBER,
        cast(null as varchar) as POLICY_BONUS_TRACKING__BONUS_AMOUNT,
        cast(null as varchar) as POLICY_BONUS_TRACKING__BONUS_SLAB,
        cast(null as varchar) as POLICY_BONUS_TRACKING__BONUS_TYPE,
        cast(null as varchar) as POLICY_BONUS_TRACKING__CUMULATIVE_BONUS_PERCENTAGE,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_list_of_covers_cover_set_attr_pv') }} t0
    where (nullif('COV:' || nullif(trim(t0.cover),''), '')) is not null

    union all

    -- branch 1: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW
    select
        null,
        nullif('RECEIPT:' || nullif(trim(t0.stamp_receipt_no),''), '') as FINANCIAL_TRANSACTION_BK,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.stamp_receipt_no as FIN_RECEIPT__RECEIPT_NUMBER,
        null, null,
        t0.cumulative_bonus_options as POLICY_BONUS_TRACKING__BONUS_TYPE,
        t0.cumulative_bonus_ as POLICY_BONUS_TRACKING__CUMULATIVE_BONUS_PERCENTAGE,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (coalesce(nullif('RECEIPT:' || nullif(trim(t0.stamp_receipt_no),''), ''), nullif(nullif(trim(j2.policy_number),''), ''))) is not null

    union all

    -- branch 2: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS
    select
        nullif('COV:' || nullif(trim(t0.benefit_code),''), '') as COVERAGE_BK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.mandatory_optional as COVERAGE_DEFINITION__MANDATORY_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits') }} t0
    where (nullif('COV:' || nullif(trim(t0.benefit_code),''), '')) is not null

    union all

    -- branch 3: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW
    select
        nullif('COV:' || nullif(trim(t0.cover_code),''), '') as COVERAGE_BK,
        nullif('FINTXN:COVER-PREMIUM:' || ('COV:' || coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ) || ':' || coalesce(t0.member_code,'') || ':' || coalesce(t0.cover_code,'')), '') as FINANCIAL_TRANSACTION_BK,
        nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), '') as POLICY_BK,
        t0.cover_level_base_currency as COMMON_MONETARY_CONTEXT__BASE_CURRENCY_CODE,
        t0.cover_level_transaction_currency as COMMON_MONETARY_CONTEXT__CURRENCY_CODE,
        null,
        t0.cover_code as COVERAGE_DEFINITION__COVERAGE_CODE,
        t0.cover_description as COVERAGE_DEFINITION__COVERAGE_DESCRIPTION,
        t0.cover_display_name as COVERAGE_DEFINITION__COVERAGE_DISPLAY_NAME,
        t0.medical_cover_groups as COVERAGE_DEFINITION__COVERAGE_GROUP,
        t0.cover_name as COVERAGE_DEFINITION__COVERAGE_NAME,
        t0.type_of_cover as COVERAGE_DEFINITION__COVERAGE_TYPE,
        t0.mandatoryoptional as COVERAGE_DEFINITION__MANDATORY_INDICATOR,
        null, null, null, null, null, null, null, null, null,
        t0.super_cumulative_bonus_option as POLICY_BONUS_TRACKING__BONUS_SLAB,
        null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_benefits_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_benefits') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (coalesce(nullif('COV:' || nullif(trim(t0.cover_code),''), ''), nullif('FINTXN:COVER-PREMIUM:' || ('COV:' || coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ) || ':' || coalesce(t0.member_code,'') || ':' || coalesce(t0.cover_code,'')), ''), nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), ''))) is not null

    union all

    -- branch 4: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j3.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.total_cumulative_bonus as POLICY_BONUS_TRACKING__BONUS_AMOUNT,
        t0.super_cumulative_bonus_option as POLICY_BONUS_TRACKING__BONUS_SLAB,
        t0.cumulative_bonus_options as POLICY_BONUS_TRACKING__BONUS_TYPE,
        t0.super_ncb_percentage as POLICY_BONUS_TRACKING__CUMULATIVE_BONUS_PERCENTAGE,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_number),''), '')) is not null

    union all

    -- branch 5: MAXI_HLTH_UWR_VW_DATA_MEMBER_DETAILS_TAB_GRADED_SI_DETAILS
    select
        null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.cb as POLICY_BONUS_TRACKING__BONUS_AMOUNT,
        null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_memd_tab_graded_si_dtls') }} t0
    left join {{ ref('stg_mxh__uwr_memd_tab') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 6: MAXI_HLTH_UWR_VW_DATA_MEMBER_RIDER_DETAILS
    select
        nullif('COV:' || nullif(trim(t0.cover_code),''), '') as COVERAGE_BK,
        null, null, null, null, null, null, null, null, null,
        t0.cover_name as COVERAGE_DEFINITION__COVERAGE_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_member_rider_dtls') }} t0
    where (nullif('COV:' || nullif(trim(t0.cover_code),''), '')) is not null

    union all

    -- branch 7: MAXI_HLTH_UWR_VW_DATA_PREMIUM_CALCULATION_DETAILS
    select
        nullif('COV:' || nullif(trim(t0.cover),''), '') as COVERAGE_BK,
        null, null, null, null, null, null, null, null, null,
        t0.cover_name as COVERAGE_DEFINITION__COVERAGE_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_premium_calculation_dtls') }} t0
    where (nullif('COV:' || nullif(trim(t0.cover),''), '')) is not null

    union all

    -- branch 8: MAXI_HLTH_UWR_VW_DATA_RECEIPT_DETAILS_LIST
    select
        null,
        nullif('RCPT:' || nullif(trim(t0.receipt_number),''), '') as FINANCIAL_TRANSACTION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.instrument_date as FIN_RECEIPT__INSTRUMENT_DATE,
        t0.instrument_number as FIN_RECEIPT__INSTRUMENT_REFERENCE,
        t0.instrument_mode as FIN_RECEIPT__INSTRUMENT_TYPE,
        null,
        t0.instrument_status as FIN_RECEIPT__REALISATION_STATUS,
        null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_receipt_dtls_list') }} t0
    where (nullif('RCPT:' || nullif(trim(t0.receipt_number),''), '')) is not null

    union all

    -- branch 9: MAXI_HLTH_UWR_VW_DATA_VIEW_COLLECTIONS
    select
        null,
        nullif('UWR_COLLECTION:' || nullif(trim(t0.collection_payment_number),''), '') as FINANCIAL_TRANSACTION_BK,
        null, null,
        t0.currency as COMMON_MONETARY_CONTEXT__CURRENCY_CODE,
        t0.currency_rate as COMMON_MONETARY_CONTEXT__EXCHANGE_RATE,
        null, null, null, null, null, null, null,
        t0.collection_payment_amount as FIN_RECEIPT__AMOUNT_RECEIVED,
        t0.chq_ins_date as FIN_RECEIPT__INSTRUMENT_DATE,
        null,
        t0.chq_ins_type as FIN_RECEIPT__INSTRUMENT_TYPE,
        t0.received_from as FIN_RECEIPT__PAYER_NAME,
        null,
        t0.date_of_collection_payment as FIN_RECEIPT__RECEIPT_DATE,
        null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_view_collections') }} t0
    where (nullif('UWR_COLLECTION:' || nullif(trim(t0.collection_payment_number),''), '')) is not null

)

select
    COVERAGE_BK,
    FINANCIAL_TRANSACTION_BK,
    POLICY_BK,
    first_value(COMMON_MONETARY_CONTEXT__BASE_CURRENCY_CODE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_MONETARY_CONTEXT__BASE_CURRENCY_CODE,
    first_value(COMMON_MONETARY_CONTEXT__CURRENCY_CODE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_MONETARY_CONTEXT__CURRENCY_CODE,
    first_value(COMMON_MONETARY_CONTEXT__EXCHANGE_RATE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_MONETARY_CONTEXT__EXCHANGE_RATE,
    first_value(COVERAGE_DEFINITION__COVERAGE_CODE) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COVERAGE_DEFINITION__COVERAGE_CODE,
    first_value(COVERAGE_DEFINITION__COVERAGE_DESCRIPTION) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COVERAGE_DEFINITION__COVERAGE_DESCRIPTION,
    first_value(COVERAGE_DEFINITION__COVERAGE_DISPLAY_NAME) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COVERAGE_DEFINITION__COVERAGE_DISPLAY_NAME,
    first_value(COVERAGE_DEFINITION__COVERAGE_GROUP) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COVERAGE_DEFINITION__COVERAGE_GROUP,
    first_value(COVERAGE_DEFINITION__COVERAGE_NAME) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COVERAGE_DEFINITION__COVERAGE_NAME,
    first_value(COVERAGE_DEFINITION__COVERAGE_TYPE) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COVERAGE_DEFINITION__COVERAGE_TYPE,
    first_value(COVERAGE_DEFINITION__MANDATORY_INDICATOR) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COVERAGE_DEFINITION__MANDATORY_INDICATOR,
    first_value(FIN_RECEIPT__AMOUNT_RECEIVED) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FIN_RECEIPT__AMOUNT_RECEIVED,
    first_value(FIN_RECEIPT__INSTRUMENT_DATE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FIN_RECEIPT__INSTRUMENT_DATE,
    first_value(FIN_RECEIPT__INSTRUMENT_REFERENCE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FIN_RECEIPT__INSTRUMENT_REFERENCE,
    first_value(FIN_RECEIPT__INSTRUMENT_TYPE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FIN_RECEIPT__INSTRUMENT_TYPE,
    first_value(FIN_RECEIPT__PAYER_NAME) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FIN_RECEIPT__PAYER_NAME,
    first_value(FIN_RECEIPT__REALISATION_STATUS) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FIN_RECEIPT__REALISATION_STATUS,
    first_value(FIN_RECEIPT__RECEIPT_DATE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FIN_RECEIPT__RECEIPT_DATE,
    first_value(FIN_RECEIPT__RECEIPT_NUMBER) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FIN_RECEIPT__RECEIPT_NUMBER,
    first_value(POLICY_BONUS_TRACKING__BONUS_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_BONUS_TRACKING__BONUS_AMOUNT,
    first_value(POLICY_BONUS_TRACKING__BONUS_SLAB) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_BONUS_TRACKING__BONUS_SLAB,
    first_value(POLICY_BONUS_TRACKING__BONUS_TYPE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_BONUS_TRACKING__BONUS_TYPE,
    first_value(POLICY_BONUS_TRACKING__CUMULATIVE_BONUS_PERCENTAGE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_BONUS_TRACKING__CUMULATIVE_BONUS_PERCENTAGE
from merged
