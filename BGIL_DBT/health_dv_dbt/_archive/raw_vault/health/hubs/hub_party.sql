{{
    config(
        materialized='incremental',
        unique_key='party_hkey'
    )
}}

-- Hub: HUB_PARTY (Party)
-- Business key: Party Identifier (enterprise-issued canonical party key)
-- Source: {{ ref('int_health__hub_party') }} (unions 115 contributing tables).
-- Hash key is namespaced with the hub code, so this hub's hkey can never collide with another
-- hub's hkey even where both are sourced from literally the same raw column value (e.g.
-- HUB_QUOTE and HUB_PROPOSAL both keyed by QUOTE_REF_NO on some Health tables).
-- This load does no joins.

with source_data as (

    select * from {{ ref('int_health__hub_party') }}

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_PARTY'", 'business_key']) }} as party_hkey,
        business_key as party_bk,
        record_source,
        current_timestamp() as load_dts
    from source_data

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by party_hkey order by record_source) = 1

)

select party_hkey, party_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where party_hkey not in (select party_hkey from {{ this }})
{% endif %}
