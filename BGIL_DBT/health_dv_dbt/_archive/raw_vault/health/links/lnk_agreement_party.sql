{{
    config(
        materialized='incremental',
        unique_key='agreement_party_hkey'
    )
}}

-- Link: LNK_AGREEMENT_PARTY (Agreement Party) -- Associative
-- Associates parties (intermediary, provider, vendor, bank) to a governing agreement.
-- Source: {{ ref('int_health__lnk_agreement_party') }} (unions 4 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_agreement_party') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_AGREEMENT'", 'agreement_bk']) }} as agreement_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_PARTY'", 'party_bk']) }} as party_hkey,
        agreement_bk, party_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_AGREEMENT_PARTY'", 'agreement_hkey', 'party_hkey']) }} as agreement_party_hkey,
        agreement_hkey, agreement_bk, party_hkey, party_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by agreement_party_hkey order by record_source) = 1

)

select agreement_party_hkey, agreement_hkey, agreement_bk, party_hkey, party_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where agreement_party_hkey not in (select agreement_party_hkey from {{ this }})
{% endif %}
