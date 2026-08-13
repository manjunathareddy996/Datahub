{{
    config(
        materialized='incremental',
        unique_key='party_payment_instrument_hkey'
    )
}}

-- Link: LNK_PARTY_PAYMENT_INSTRUMENT (Party Payment Instrument) -- Associative
-- Links a party to a tokenised payment instrument it owns or uses.
-- Source: {{ ref('int_health__lnk_party_payment_instrument') }} (unions 3 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_party_payment_instrument') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_PARTY'", 'party_bk']) }} as party_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_PAYMENT_INSTRUMENT'", 'payment_instrument_bk']) }} as payment_instrument_hkey,
        party_bk, payment_instrument_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_PARTY_PAYMENT_INSTRUMENT'", 'party_hkey', 'payment_instrument_hkey']) }} as party_payment_instrument_hkey,
        party_hkey, party_bk, payment_instrument_hkey, payment_instrument_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by party_payment_instrument_hkey order by record_source) = 1

)

select party_payment_instrument_hkey, party_hkey, party_bk, payment_instrument_hkey, payment_instrument_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where party_payment_instrument_hkey not in (select party_payment_instrument_hkey from {{ this }})
{% endif %}
