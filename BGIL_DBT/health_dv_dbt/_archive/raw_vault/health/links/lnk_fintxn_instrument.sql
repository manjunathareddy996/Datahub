{{
    config(
        materialized='incremental',
        unique_key='fintxn_instrument_hkey'
    )
}}

-- Link: LNK_FINTXN_INSTRUMENT (Financial Txn Instrument) -- Associative
-- Associates the payment instrument used in a financial transaction.
-- Source: {{ ref('int_health__lnk_fintxn_instrument') }} (unions 2 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_fintxn_instrument') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_FINANCIAL_TRANSACTION'", 'financial_transaction_bk']) }} as financial_transaction_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_PAYMENT_INSTRUMENT'", 'payment_instrument_bk']) }} as payment_instrument_hkey,
        financial_transaction_bk, payment_instrument_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_FINTXN_INSTRUMENT'", 'financial_transaction_hkey', 'payment_instrument_hkey']) }} as fintxn_instrument_hkey,
        financial_transaction_hkey, financial_transaction_bk, payment_instrument_hkey, payment_instrument_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by fintxn_instrument_hkey order by record_source) = 1

)

select fintxn_instrument_hkey, financial_transaction_hkey, financial_transaction_bk, payment_instrument_hkey, payment_instrument_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where fintxn_instrument_hkey not in (select fintxn_instrument_hkey from {{ this }})
{% endif %}
