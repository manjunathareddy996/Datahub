{{
    config(
        materialized='incremental',
        unique_key='policy_hkey'
    )
}}

-- Hub: HUB_POLICY (Policy)
-- Business key: Policy Number (canonical contract key)
-- Source: {{ ref('int_health__hub_policy') }} (unions 103 contributing tables).
-- Hash key is namespaced with the hub code, so this hub's hkey can never collide with another
-- hub's hkey even where both are sourced from literally the same raw column value (e.g.
-- HUB_QUOTE and HUB_PROPOSAL both keyed by QUOTE_REF_NO on some Health tables).
-- This load does no joins.

with source_data as (

    select * from {{ ref('int_health__hub_policy') }}

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_POLICY'", 'business_key']) }} as policy_hkey,
        business_key as policy_bk,
        record_source,
        current_timestamp() as load_dts
    from source_data

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by policy_hkey order by record_source) = 1

)

select policy_hkey, policy_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where policy_hkey not in (select policy_hkey from {{ this }})
{% endif %}
