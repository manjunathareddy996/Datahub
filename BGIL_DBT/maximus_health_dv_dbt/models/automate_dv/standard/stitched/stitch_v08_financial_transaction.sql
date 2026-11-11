-- CENTRAL VIEW v08_financial_transaction -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PAYMENT_CLAIM_PAYMENT_DETAIL_ATTRIBUTES_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_VIEW_COLLECTIONS
-- Walk tables, joined only to resolve spine keys (not counted):
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_FINTXN_CLAIM_PAYMENT
--   SAT_AUG_FINTXN_HEADER
--   SAT_AUG_FIN_RECEIPT
--   SAT_FINTXN_ACCOUNTING
--   SAT_FINTXN_HEADER
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_FINTXN_INSTRUMENT
--   LNK_FINTXN_POLICY
--   LNK_POLICY_PAYMENT_INSTRUMENT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PAYMENT_CLAIM_PAYMENT_DETAIL_ATTRIBUTES_PIVOT_VW
    select
        nullif('CLMPAY:' || coalesce( nullif(trim(t0.reference_no),'') , nullif(trim(t0.utr_number),'') , nullif(trim(t0.ddcheque_reference),'') ), '') as FINANCIAL_TRANSACTION_BK,
        cast(null as varchar) as PAYMENT_INSTRUMENT_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as number) as __LNK_FINTXN_INSTRUMENT,
        cast(null as number) as __LNK_FINTXN_POLICY,
        cast(null as number) as __LNK_POLICY_PAYMENT_INSTRUMENT,
        t0.fixed_payment as AUG_FINTXN_CLAIM_PAYMENT__FIXED_PAYMENT,
        t0.impacted_cover as AUG_FINTXN_CLAIM_PAYMENT__IMPACTED_COVER_NAME,
        t0.neft_status as AUG_FINTXN_CLAIM_PAYMENT__NEFT_STATUS,
        t0.approved_date as AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_APPROVAL_DATE,
        t0.approved_by_ as AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_APPROVED_BY_REFERENCE,
        t0.start_date as AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_DETAIL_EFFECTIVE_FROM_DATE,
        t0.end_date as AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_DETAIL_EFFECTIVE_TO_DATE,
        t0.utr_date as AUG_FINTXN_CLAIM_PAYMENT__UTR_DATE,
        cast(null as varchar) as AUG_FINTXN_HEADER__CREATED_BY_USER_REFERENCE,
        cast(null as varchar) as AUG_FINTXN_HEADER__OTHER_APPROVED_SOURCE,
        cast(null as varchar) as AUG_FINTXN_HEADER__POSTED_BY_USER_REFERENCE,
        cast(null as varchar) as AUG_FIN_RECEIPT__BANK_SCROLL_DATE,
        cast(null as varchar) as FINTXN_ACCOUNTING__CREDIT_ACCOUNT_REFERENCE,
        cast(null as varchar) as FINTXN_ACCOUNTING__DEBIT_ACCOUNT_REFERENCE,
        cast(null as varchar) as FINTXN_ACCOUNTING__VOUCHER_NUMBER,
        cast(null as varchar) as FINTXN_HEADER__GROSS_AMOUNT,
        cast(null as varchar) as FINTXN_HEADER__NARRATION,
        cast(null as varchar) as FINTXN_HEADER__NET_AMOUNT,
        cast(null as varchar) as FINTXN_HEADER__POSTING_DATE,
        cast(null as varchar) as FINTXN_HEADER__SOURCE_REFERENCE_NUMBER,
        cast(null as varchar) as FINTXN_HEADER__TRANSACTION_CHANNEL,
        t0.inout as FINTXN_HEADER__TRANSACTION_DIRECTION,
        cast(null as varchar) as FINTXN_HEADER__TRANSACTION_SUB_TYPE,
        cast(null as varchar) as FINTXN_HEADER__TRANSACTION_TYPE,
        cast(null as varchar) as FINTXN_HEADER__VALUE_DATE,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claim_payment_claim_payment_detail_attrs_pv') }} t0
    where (nullif('CLMPAY:' || coalesce( nullif(trim(t0.reference_no),'') , nullif(trim(t0.utr_number),'') , nullif(trim(t0.ddcheque_reference),'') ), '')) is not null

    union all

    -- branch 1: MAXI_HLTH_UWR_VW_DATA_VIEW_COLLECTIONS
    select
        nullif('UWR_COLLECTION:' || nullif(trim(t0.collection_payment_number),''), '') as FINANCIAL_TRANSACTION_BK,
        nullif('CHQ:' || nullif(trim(coalesce(upper(trim(t0.drawee_bank_name)),'') || '#' || coalesce(trim(t0.chq_ins_number),'')), '#'), '') as PAYMENT_INSTRUMENT_BK,
        nullif(t0.policy_quotation_debit_note_no, '') as POLICY_BK,
        1 as __LNK_FINTXN_INSTRUMENT,
        1 as __LNK_FINTXN_POLICY,
        1 as __LNK_POLICY_PAYMENT_INSTRUMENT,
        null, null, null, null, null, null, null, null,
        t0.created_by as AUG_FINTXN_HEADER__CREATED_BY_USER_REFERENCE,
        t0.other_approved_src as AUG_FINTXN_HEADER__OTHER_APPROVED_SOURCE,
        t0.posted_by as AUG_FINTXN_HEADER__POSTED_BY_USER_REFERENCE,
        t0.scroll_date as AUG_FIN_RECEIPT__BANK_SCROLL_DATE,
        t0.credit_account_code as FINTXN_ACCOUNTING__CREDIT_ACCOUNT_REFERENCE,
        t0.account_code as FINTXN_ACCOUNTING__DEBIT_ACCOUNT_REFERENCE,
        t0.voucher_number as FINTXN_ACCOUNTING__VOUCHER_NUMBER,
        t0.amount as FINTXN_HEADER__GROSS_AMOUNT,
        t0.narration as FINTXN_HEADER__NARRATION,
        t0.amount_to_be_collected_paid as FINTXN_HEADER__NET_AMOUNT,
        t0.date_of_posting as FINTXN_HEADER__POSTING_DATE,
        t0.reference_no as FINTXN_HEADER__SOURCE_REFERENCE_NUMBER,
        t0.source_of_collection as FINTXN_HEADER__TRANSACTION_CHANNEL,
        null,
        t0.collection_sub_type as FINTXN_HEADER__TRANSACTION_SUB_TYPE,
        t0.collection_payment_type as FINTXN_HEADER__TRANSACTION_TYPE,
        t0.effective_date as FINTXN_HEADER__VALUE_DATE,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_view_collections') }} t0
    where (coalesce(nullif('CHQ:' || nullif(trim(coalesce(upper(trim(t0.drawee_bank_name)),'') || '#' || coalesce(trim(t0.chq_ins_number),'')), '#'), ''), nullif('UWR_COLLECTION:' || nullif(trim(t0.collection_payment_number),''), ''), nullif(t0.policy_quotation_debit_note_no, ''))) is not null

)

select
    FINANCIAL_TRANSACTION_BK,
    PAYMENT_INSTRUMENT_BK,
    POLICY_BK,
    __LNK_FINTXN_INSTRUMENT,
    __LNK_FINTXN_POLICY,
    __LNK_POLICY_PAYMENT_INSTRUMENT,
    first_value(AUG_FINTXN_CLAIM_PAYMENT__FIXED_PAYMENT) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CLAIM_PAYMENT__FIXED_PAYMENT,
    first_value(AUG_FINTXN_CLAIM_PAYMENT__IMPACTED_COVER_NAME) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CLAIM_PAYMENT__IMPACTED_COVER_NAME,
    first_value(AUG_FINTXN_CLAIM_PAYMENT__NEFT_STATUS) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CLAIM_PAYMENT__NEFT_STATUS,
    first_value(AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_APPROVAL_DATE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_APPROVAL_DATE,
    first_value(AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_APPROVED_BY_REFERENCE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_APPROVED_BY_REFERENCE,
    first_value(AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_DETAIL_EFFECTIVE_FROM_DATE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_DETAIL_EFFECTIVE_FROM_DATE,
    first_value(AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_DETAIL_EFFECTIVE_TO_DATE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_DETAIL_EFFECTIVE_TO_DATE,
    first_value(AUG_FINTXN_CLAIM_PAYMENT__UTR_DATE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CLAIM_PAYMENT__UTR_DATE,
    first_value(AUG_FINTXN_HEADER__CREATED_BY_USER_REFERENCE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_HEADER__CREATED_BY_USER_REFERENCE,
    first_value(AUG_FINTXN_HEADER__OTHER_APPROVED_SOURCE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_HEADER__OTHER_APPROVED_SOURCE,
    first_value(AUG_FINTXN_HEADER__POSTED_BY_USER_REFERENCE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_HEADER__POSTED_BY_USER_REFERENCE,
    first_value(AUG_FIN_RECEIPT__BANK_SCROLL_DATE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FIN_RECEIPT__BANK_SCROLL_DATE,
    first_value(FINTXN_ACCOUNTING__CREDIT_ACCOUNT_REFERENCE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_ACCOUNTING__CREDIT_ACCOUNT_REFERENCE,
    first_value(FINTXN_ACCOUNTING__DEBIT_ACCOUNT_REFERENCE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_ACCOUNTING__DEBIT_ACCOUNT_REFERENCE,
    first_value(FINTXN_ACCOUNTING__VOUCHER_NUMBER) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_ACCOUNTING__VOUCHER_NUMBER,
    first_value(FINTXN_HEADER__GROSS_AMOUNT) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_HEADER__GROSS_AMOUNT,
    first_value(FINTXN_HEADER__NARRATION) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_HEADER__NARRATION,
    first_value(FINTXN_HEADER__NET_AMOUNT) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_HEADER__NET_AMOUNT,
    first_value(FINTXN_HEADER__POSTING_DATE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_HEADER__POSTING_DATE,
    first_value(FINTXN_HEADER__SOURCE_REFERENCE_NUMBER) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_HEADER__SOURCE_REFERENCE_NUMBER,
    first_value(FINTXN_HEADER__TRANSACTION_CHANNEL) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_HEADER__TRANSACTION_CHANNEL,
    first_value(FINTXN_HEADER__TRANSACTION_DIRECTION) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_HEADER__TRANSACTION_DIRECTION,
    first_value(FINTXN_HEADER__TRANSACTION_SUB_TYPE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_HEADER__TRANSACTION_SUB_TYPE,
    first_value(FINTXN_HEADER__TRANSACTION_TYPE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_HEADER__TRANSACTION_TYPE,
    first_value(FINTXN_HEADER__VALUE_DATE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_HEADER__VALUE_DATE
from merged
