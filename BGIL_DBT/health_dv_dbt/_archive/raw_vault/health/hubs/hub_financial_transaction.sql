{{
    config(
        materialized='incremental',
        unique_key='financial_transaction_hkey'
    )
}}

-- Hub: HUB_FINANCIAL_TRANSACTION (Financial Transaction)
-- Business key: Financial Transaction Identifier
-- Source: {{ ref('int_health__hub_financial_transaction') }} (unions 3 contributing tables).
-- Hash key is namespaced with the hub code, so this hub's hkey can never collide with another
-- hub's hkey even where both are sourced from literally the same raw column value (e.g.
-- HUB_QUOTE and HUB_PROPOSAL both keyed by QUOTE_REF_NO on some Health tables).
-- This load does no joins.

with source_data as (

    select * from {{ ref('int_health__hub_financial_transaction') }}

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_FINANCIAL_TRANSACTION'", 'business_key']) }} as financial_transaction_hkey,
        business_key as financial_transaction_bk,
        record_source,
        current_timestamp() as load_dts
    from source_data

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by financial_transaction_hkey order by record_source) = 1

)

select financial_transaction_hkey, financial_transaction_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where financial_transaction_hkey not in (select financial_transaction_hkey from {{ this }})
{% endif %}
