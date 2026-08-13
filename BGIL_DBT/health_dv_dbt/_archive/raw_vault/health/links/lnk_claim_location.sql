{{
    config(
        materialized='incremental',
        unique_key='claim_location_hkey'
    )
}}

-- Link: LNK_CLAIM_LOCATION (Claim Location) -- Associative
-- Associates loss/repair/treatment locations with a claim.
-- Source: {{ ref('int_health__lnk_claim_location') }} (unions 7 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_claim_location') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_CLAIM'", 'claim_bk']) }} as claim_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_LOCATION'", 'location_bk']) }} as location_hkey,
        claim_bk, location_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_CLAIM_LOCATION'", 'claim_hkey', 'location_hkey']) }} as claim_location_hkey,
        claim_hkey, claim_bk, location_hkey, location_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by claim_location_hkey order by record_source) = 1

)

select claim_location_hkey, claim_hkey, claim_bk, location_hkey, location_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where claim_location_hkey not in (select claim_location_hkey from {{ this }})
{% endif %}
