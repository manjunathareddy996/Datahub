{{
    config(
        materialized='incremental',
        unique_key='policy_payment_instrument_hkey'
    )
}}

-- Link: LNK_POLICY_PAYMENT_INSTRUMENT (Policy Payment Instrument) -- Associative
-- Associates the instrument used for premium collection / refund on a policy.
-- Source: {{ ref('int_health__lnk_policy_payment_instrument') }} (unions 2 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_policy_payment_instrument') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_PAYMENT_INSTRUMENT'", 'payment_instrument_bk']) }} as payment_instrument_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_POLICY'", 'policy_bk']) }} as policy_hkey,
        payment_instrument_bk, policy_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_POLICY_PAYMENT_INSTRUMENT'", 'payment_instrument_hkey', 'policy_hkey']) }} as policy_payment_instrument_hkey,
        payment_instrument_hkey, payment_instrument_bk, policy_hkey, policy_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by policy_payment_instrument_hkey order by record_source) = 1

)

select policy_payment_instrument_hkey, payment_instrument_hkey, payment_instrument_bk, policy_hkey, policy_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where policy_payment_instrument_hkey not in (select policy_payment_instrument_hkey from {{ this }})
{% endif %}
