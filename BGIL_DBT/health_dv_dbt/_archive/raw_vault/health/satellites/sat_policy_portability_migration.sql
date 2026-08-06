{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_POLICY_PORTABILITY_MIGRATION
-- Parent: HUB_POLICY
-- Multi-active grain key: none (single-active)
-- Source: {{ ref('int_health__sat_policy_portability_migration') }}. No joins in THIS load.

with source_data as (

    select parent_bk, continuity_period_granted, cumulative_bonus_ported, portability_indicator, previous_insurer_name, previous_policy_number, previous_sum_insured, record_source
    from {{ ref('int_health__sat_policy_portability_migration') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_POLICY'", 'parent_bk']) }} as policy_hkey,
        parent_bk,
        continuity_period_granted, cumulative_bonus_ported, portability_indicator, previous_insurer_name, previous_policy_number, previous_sum_insured,
        record_source
    from source_data

),

hashed as (

    select
        policy_hkey,
        continuity_period_granted, cumulative_bonus_ported, portability_indicator, previous_insurer_name, previous_policy_number, previous_sum_insured,
        {{ dbt_utils.generate_surrogate_key(['continuity_period_granted', 'cumulative_bonus_ported', 'portability_indicator', 'previous_insurer_name', 'previous_policy_number', 'previous_sum_insured']) }} as hashdiff,
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
    continuity_period_granted, cumulative_bonus_ported, portability_indicator, previous_insurer_name, previous_policy_number, previous_sum_insured,
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
