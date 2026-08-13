{{
    config(
        materialized='incremental',
        unique_key='claim_payment_instrument_hkey'
    )
}}

-- Link: LNK_CLAIM_PAYMENT_INSTRUMENT (Claim Payment Instrument) -- Associative
-- Associates the instrument used to disburse claim settlement.
-- Source: {{ ref('int_health__lnk_claim_payment_instrument') }} (unions 3 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_claim_payment_instrument') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_CLAIM'", 'claim_bk']) }} as claim_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_PAYMENT_INSTRUMENT'", 'payment_instrument_bk']) }} as payment_instrument_hkey,
        claim_bk, payment_instrument_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_CLAIM_PAYMENT_INSTRUMENT'", 'claim_hkey', 'payment_instrument_hkey']) }} as claim_payment_instrument_hkey,
        claim_hkey, claim_bk, payment_instrument_hkey, payment_instrument_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by claim_payment_instrument_hkey order by record_source) = 1

)

select claim_payment_instrument_hkey, claim_hkey, claim_bk, payment_instrument_hkey, payment_instrument_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where claim_payment_instrument_hkey not in (select claim_payment_instrument_hkey from {{ this }})
{% endif %}
