{{
    config(
        materialized='incremental',
        unique_key='policy_location_hkey'
    )
}}

-- Link: LNK_POLICY_LOCATION (Policy Risk Location) -- Associative
-- Associates risk locations covered under a policy.
-- Source: {{ ref('int_health__lnk_policy_location') }} (unions 13 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_policy_location') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_LOCATION'", 'location_bk']) }} as location_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_POLICY'", 'policy_bk']) }} as policy_hkey,
        location_bk, policy_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_POLICY_LOCATION'", 'location_hkey', 'policy_hkey']) }} as policy_location_hkey,
        location_hkey, location_bk, policy_hkey, policy_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by policy_location_hkey order by record_source) = 1

)

select policy_location_hkey, location_hkey, location_bk, policy_hkey, policy_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where policy_location_hkey not in (select policy_location_hkey from {{ this }})
{% endif %}
