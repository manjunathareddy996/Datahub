{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_FINTXN_PREMIUM
-- Parent: HUB_FINANCIAL_TRANSACTION
-- Multi-active grain key: none (single-active)
-- Source: {{ ref('int_health__sat_shared__fintxn_commission_fintxn_header_fintxn_premium_fin_receipt') }} (SHARED with sibling satellite(s)). No joins in THIS load.

with source_data as (

    select parent_bk, base_premium, collection_mode, discount_amount, gross_premium, instalment_amount, instalment_number, loading_amount, net_premium, record_source
    from {{ ref('int_health__sat_shared__fintxn_commission_fintxn_header_fintxn_premium_fin_receipt') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_FINANCIAL_TRANSACTION'", 'parent_bk']) }} as financial_transaction_hkey,
        parent_bk,
        base_premium, collection_mode, discount_amount, gross_premium, instalment_amount, instalment_number, loading_amount, net_premium,
        record_source
    from source_data

),

hashed as (

    select
        financial_transaction_hkey,
        base_premium, collection_mode, discount_amount, gross_premium, instalment_amount, instalment_number, loading_amount, net_premium,
        {{ dbt_utils.generate_surrogate_key(['base_premium', 'collection_mode', 'discount_amount', 'gross_premium', 'instalment_amount', 'instalment_number', 'loading_amount', 'net_premium']) }} as hashdiff,
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
    base_premium, collection_mode, discount_amount, gross_premium, instalment_amount, instalment_number, loading_amount, net_premium,
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
