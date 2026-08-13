{{
    config(
        materialized='incremental',
        unique_key='financial_account_hkey'
    )
}}

-- Hub: HUB_FINANCIAL_ACCOUNT (Financial Account)
-- Business key: Financial Account Identifier (GL / control / customer / float account key)
-- Source: {{ ref('int_health__hub_financial_account') }} (unions 18 contributing tables).
-- Hash key is namespaced with the hub code, so this hub's hkey can never collide with another
-- hub's hkey even where both are sourced from literally the same raw column value (e.g.
-- HUB_QUOTE and HUB_PROPOSAL both keyed by QUOTE_REF_NO on some Health tables).
-- This load does no joins.

with source_data as (

    select * from {{ ref('int_health__hub_financial_account') }}

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_FINANCIAL_ACCOUNT'", 'business_key']) }} as financial_account_hkey,
        business_key as financial_account_bk,
        record_source,
        current_timestamp() as load_dts
    from source_data

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by financial_account_hkey order by record_source) = 1

)

select financial_account_hkey, financial_account_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where financial_account_hkey not in (select financial_account_hkey from {{ this }})
{% endif %}
