{{
    config(
        materialized='incremental',
        unique_key='fintxn_claim_hkey'
    )
}}

-- Link: LNK_FINTXN_CLAIM (Financial Txn Claim) -- Transactional
-- Associates a claim payment / recovery / salvage transaction with its claim.
-- Source: {{ ref('int_health__lnk_fintxn_claim') }} (unions 2 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_fintxn_claim') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_CLAIM'", 'claim_bk']) }} as claim_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_FINANCIAL_TRANSACTION'", 'financial_transaction_bk']) }} as financial_transaction_hkey,
        claim_bk, financial_transaction_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_FINTXN_CLAIM'", 'claim_hkey', 'financial_transaction_hkey']) }} as fintxn_claim_hkey,
        claim_hkey, claim_bk, financial_transaction_hkey, financial_transaction_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by fintxn_claim_hkey order by record_source) = 1

)

select fintxn_claim_hkey, claim_hkey, claim_bk, financial_transaction_hkey, financial_transaction_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where fintxn_claim_hkey not in (select fintxn_claim_hkey from {{ this }})
{% endif %}
