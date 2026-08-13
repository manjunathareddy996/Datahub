{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_ACCOUNT_BALANCE
-- Parent: HUB_FINANCIAL_ACCOUNT
-- Multi-active grain key: none (single-active)
-- Single contributing source table: no intermediate view created (collapsed). No joins in THIS load.

with source_data as (

    select parent_bk, opening_balance, record_source
    from (
        select distinct
            plc_loan_acc_no as parent_bk,
            nullif(trim(to_varchar(plc_sactioned_loan_amt)), '') as opening_balance,
            'BA_HCP_PROD_8439_CLH_LOADER' as record_source
        from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
        where plc_loan_acc_no is not null
    )

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_FINANCIAL_ACCOUNT'", 'parent_bk']) }} as financial_account_hkey,
        parent_bk,
        opening_balance,
        record_source
    from source_data

),

hashed as (

    select
        financial_account_hkey,
        opening_balance,
        {{ dbt_utils.generate_surrogate_key(['opening_balance']) }} as hashdiff,
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
    opening_balance,
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
