{{
    config(
        materialized='incremental',
        unique_key='party_channel_hkey'
    )
}}

-- Link: LNK_PARTY_CHANNEL (Party via Channel) -- Associative
-- Associates a party (intermediary) with the distribution channel it belongs to.
-- Source: {{ ref('int_health__lnk_party_channel') }} (unions 35 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_party_channel') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_DISTRIBUTION_CHANNEL'", 'distribution_channel_bk']) }} as distribution_channel_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_PARTY'", 'party_bk']) }} as party_hkey,
        distribution_channel_bk, party_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_PARTY_CHANNEL'", 'distribution_channel_hkey', 'party_hkey']) }} as party_channel_hkey,
        distribution_channel_hkey, distribution_channel_bk, party_hkey, party_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by party_channel_hkey order by record_source) = 1

)

select party_channel_hkey, distribution_channel_hkey, distribution_channel_bk, party_hkey, party_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where party_channel_hkey not in (select party_channel_hkey from {{ this }})
{% endif %}
