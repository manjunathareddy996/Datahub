{{
    config(
        materialized='incremental',
        unique_key='fintxn_policy_hkey'
    )
}}

-- Link: LNK_FINTXN_POLICY (Financial Txn Policy) -- Transactional
-- Associates a premium / refund / commission transaction with its policy.
-- Source: {{ ref('int_health__lnk_fintxn_policy') }} (unions 3 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_fintxn_policy') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_FINANCIAL_TRANSACTION'", 'financial_transaction_bk']) }} as financial_transaction_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_POLICY'", 'policy_bk']) }} as policy_hkey,
        financial_transaction_bk, policy_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_FINTXN_POLICY'", 'financial_transaction_hkey', 'policy_hkey']) }} as fintxn_policy_hkey,
        financial_transaction_hkey, financial_transaction_bk, policy_hkey, policy_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by fintxn_policy_hkey order by record_source) = 1

)

select fintxn_policy_hkey, financial_transaction_hkey, financial_transaction_bk, policy_hkey, policy_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where fintxn_policy_hkey not in (select fintxn_policy_hkey from {{ this }})
{% endif %}
