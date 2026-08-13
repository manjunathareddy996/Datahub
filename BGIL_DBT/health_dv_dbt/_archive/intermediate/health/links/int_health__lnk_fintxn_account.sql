-- Intermediate harmonisation view for LNK_FINTXN_ACCOUNT (Financial Txn Account).
-- Derived link: co-occurrence of the member hub business keys (explicit/discovered/mapper-
-- confirmed) on the same Health source row is treated as evidence of the association.
-- Pure UNION ALL: 0-join complexity.

with unioned as (

    select distinct
        loan_accno as financial_account_bk,
        ptransaction_id as financial_transaction_bk,
        'BJAZ_HEALTH_WEBSERVICE_INFO' as record_source
    from {{ ref('stg_health__bjaz_health_webservice_info') }}
    where loan_accno is not null and ptransaction_id is not null

    union all

    select distinct
        bank_ac_no as financial_account_bk,
        claim_no || '|' || utr_no as financial_transaction_bk,
        'BJAZ_HM_HCM_EXTRACT' as record_source
    from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
    where bank_ac_no is not null and claim_no is not null and utr_no is not null

)

select distinct financial_account_bk, financial_transaction_bk, record_source
from unioned
