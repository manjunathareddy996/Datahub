{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_ACCOUNT_DEFINITION
-- Parent: HUB_FINANCIAL_ACCOUNT
-- Multi-active grain key: none (single-active)
-- Source: {{ ref('int_health__sat_account_definition') }}. No joins in THIS load.

with source_data as (

    select parent_bk, account_category, account_type, closing_date, record_source
    from {{ ref('int_health__sat_account_definition') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_FINANCIAL_ACCOUNT'", 'parent_bk']) }} as financial_account_hkey,
        parent_bk,
        account_category, account_type, closing_date,
        record_source
    from source_data

),

hashed as (

    select
        financial_account_hkey,
        account_category, account_type, closing_date,
        {{ dbt_utils.generate_surrogate_key(['account_category', 'account_type', 'closing_date']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by financial_account_hkey, hashdiff
        order by record_source
    ) = 1

)

select
    financial_account_hkey,
    account_category, account_type, closing_date,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.financial_account_hkey = d.financial_account_hkey
      and t.hashdiff = d.hashdiff
)
{% endif %}
