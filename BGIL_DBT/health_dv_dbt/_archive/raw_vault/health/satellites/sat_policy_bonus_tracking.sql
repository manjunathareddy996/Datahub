{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_POLICY_BONUS_TRACKING
-- Parent: HUB_POLICY
-- Multi-active grain key: none (single-active)
-- Source: {{ ref('int_health__sat_policy_bonus_tracking') }}. No joins in THIS load.

with source_data as (

    select parent_bk, bonus_amount, cumulative_bonus_percentage, record_source
    from {{ ref('int_health__sat_policy_bonus_tracking') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_POLICY'", 'parent_bk']) }} as policy_hkey,
        parent_bk,
        bonus_amount, cumulative_bonus_percentage,
        record_source
    from source_data

),

hashed as (

    select
        policy_hkey,
        bonus_amount, cumulative_bonus_percentage,
        {{ dbt_utils.generate_surrogate_key(['bonus_amount', 'cumulative_bonus_percentage']) }} as hashdiff,
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
    bonus_amount, cumulative_bonus_percentage,
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
