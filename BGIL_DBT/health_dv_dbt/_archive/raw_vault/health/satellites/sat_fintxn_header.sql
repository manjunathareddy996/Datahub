{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_FINTXN_HEADER
-- Parent: HUB_FINANCIAL_TRANSACTION
-- Multi-active grain key: none (single-active)
-- Source: {{ ref('int_health__sat_shared__fintxn_commission_fintxn_header_fintxn_premium_fin_receipt') }} (SHARED with sibling satellite(s)). No joins in THIS load.

with source_data as (

    select parent_bk, gross_amount, narration, originating_system_reference, source_reference_number, transaction_date, record_source
    from {{ ref('int_health__sat_shared__fintxn_commission_fintxn_header_fintxn_premium_fin_receipt') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_FINANCIAL_TRANSACTION'", 'parent_bk']) }} as financial_transaction_hkey,
        parent_bk,
        gross_amount, narration, originating_system_reference, source_reference_number, transaction_date,
        record_source
    from source_data

),

hashed as (

    select
        financial_transaction_hkey,
        gross_amount, narration, originating_system_reference, source_reference_number, transaction_date,
        {{ dbt_utils.generate_surrogate_key(['gross_amount', 'narration', 'originating_system_reference', 'source_reference_number', 'transaction_date']) }} as hashdiff,
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
    gross_amount, narration, originating_system_reference, source_reference_number, transaction_date,
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
