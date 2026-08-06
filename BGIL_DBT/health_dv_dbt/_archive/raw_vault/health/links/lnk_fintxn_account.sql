{{
    config(
        materialized='incremental',
        unique_key='fintxn_account_hkey'
    )
}}

-- Link: LNK_FINTXN_ACCOUNT (Financial Txn Account) -- Transactional
-- Posts a financial transaction against ledger/control accounts (debit/credit).
-- Source: {{ ref('int_health__lnk_fintxn_account') }} (unions 2 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_fintxn_account') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_FINANCIAL_ACCOUNT'", 'financial_account_bk']) }} as financial_account_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_FINANCIAL_TRANSACTION'", 'financial_transaction_bk']) }} as financial_transaction_hkey,
        financial_account_bk, financial_transaction_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_FINTXN_ACCOUNT'", 'financial_account_hkey', 'financial_transaction_hkey']) }} as fintxn_account_hkey,
        financial_account_hkey, financial_account_bk, financial_transaction_hkey, financial_transaction_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by fintxn_account_hkey order by record_source) = 1

)

select fintxn_account_hkey, financial_account_hkey, financial_account_bk, financial_transaction_hkey, financial_transaction_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where fintxn_account_hkey not in (select fintxn_account_hkey from {{ this }})
{% endif %}
