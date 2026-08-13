{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_POLICY_LIFECYCLE
-- Parent: HUB_POLICY
-- Multi-active grain key: none (single-active)
-- Source: {{ ref('int_health__sat_shared__policy_lifecycle_product_health_membership_rules_product_rating_factor') }} (SHARED with sibling satellite(s)). No joins in THIS load.

with source_data as (

    select parent_bk, termination_date, record_source
    from {{ ref('int_health__sat_shared__policy_lifecycle_product_health_membership_rules_product_rating_factor') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_POLICY'", 'parent_bk']) }} as policy_hkey,
        parent_bk,
        termination_date,
        record_source
    from source_data

),

hashed as (

    select
        policy_hkey,
        termination_date,
        {{ dbt_utils.generate_surrogate_key(['termination_date']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by policy_hkey, hashdiff
        order by record_source
    ) = 1

)

select
    policy_hkey,
    termination_date,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.policy_hkey = d.policy_hkey
      and t.hashdiff = d.hashdiff
)
{% endif %}
