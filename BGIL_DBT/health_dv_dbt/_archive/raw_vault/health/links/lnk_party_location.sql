{{
    config(
        materialized='incremental',
        unique_key='party_location_hkey'
    )
}}

-- Link: LNK_PARTY_LOCATION (Party at Location) -- Associative
-- Associates a party with an address/location it occupies or operates from.
-- Source: {{ ref('int_health__lnk_party_location') }} (unions 8 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_party_location') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_LOCATION'", 'location_bk']) }} as location_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_PARTY'", 'party_bk']) }} as party_hkey,
        location_bk, party_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_PARTY_LOCATION'", 'location_hkey', 'party_hkey']) }} as party_location_hkey,
        location_hkey, location_bk, party_hkey, party_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by party_location_hkey order by record_source) = 1

)

select party_location_hkey, location_hkey, location_bk, party_hkey, party_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where party_location_hkey not in (select party_location_hkey from {{ this }})
{% endif %}
