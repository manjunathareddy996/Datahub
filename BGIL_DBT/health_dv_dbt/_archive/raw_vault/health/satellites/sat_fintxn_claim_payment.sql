{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_FINTXN_CLAIM_PAYMENT
-- Parent: HUB_FINANCIAL_TRANSACTION
-- Multi-active grain key: none (single-active)
-- Source: {{ ref('int_health__sat_fintxn_claim_payment') }}. No joins in THIS load.

with source_data as (

    select parent_bk, cheque_date, cheque_dispatch_date, cheque_received_date, net_paid_amount, payment_date, payment_mode, payment_status, tds_on_claim_amount, utr_number, record_source
    from {{ ref('int_health__sat_fintxn_claim_payment') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_FINANCIAL_TRANSACTION'", 'parent_bk']) }} as financial_transaction_hkey,
        parent_bk,
        cheque_date, cheque_dispatch_date, cheque_received_date, net_paid_amount, payment_date, payment_mode, payment_status, tds_on_claim_amount, utr_number,
        record_source
    from source_data

),

hashed as (

    select
        financial_transaction_hkey,
        cheque_date, cheque_dispatch_date, cheque_received_date, net_paid_amount, payment_date, payment_mode, payment_status, tds_on_claim_amount, utr_number,
        {{ dbt_utils.generate_surrogate_key(['cheque_date', 'cheque_dispatch_date', 'cheque_received_date', 'net_paid_amount', 'payment_date', 'payment_mode', 'payment_status', 'tds_on_claim_amount', 'utr_number']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by financial_transaction_hkey, hashdiff
        order by record_source
    ) = 1

)

select
    financial_transaction_hkey,
    cheque_date, cheque_dispatch_date, cheque_received_date, net_paid_amount, payment_date, payment_mode, payment_status, tds_on_claim_amount, utr_number,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.financial_transaction_hkey = d.financial_transaction_hkey
      and t.hashdiff = d.hashdiff
)
{% endif %}
