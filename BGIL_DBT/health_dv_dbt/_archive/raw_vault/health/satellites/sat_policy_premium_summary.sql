{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_POLICY_PREMIUM_SUMMARY
-- Parent: HUB_POLICY
-- Multi-active grain key: none (single-active)
-- Source: {{ ref('int_health__sat_policy_premium_summary') }}. No joins in THIS load.

with source_data as (

    select parent_bk, add_on_premium, base_premium, gross_premium, group_discount_amount, instalment_count, long_term_discount_amount, net_premium, terrorism_premium, total_premium_collected, record_source
    from {{ ref('int_health__sat_policy_premium_summary') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_POLICY'", 'parent_bk']) }} as policy_hkey,
        parent_bk,
        add_on_premium, base_premium, gross_premium, group_discount_amount, instalment_count, long_term_discount_amount, net_premium, terrorism_premium, total_premium_collected,
        record_source
    from source_data

),

hashed as (

    select
        policy_hkey,
        add_on_premium, base_premium, gross_premium, group_discount_amount, instalment_count, long_term_discount_amount, net_premium, terrorism_premium, total_premium_collected,
        {{ dbt_utils.generate_surrogate_key(['add_on_premium', 'base_premium', 'gross_premium', 'group_discount_amount', 'instalment_count', 'long_term_discount_amount', 'net_premium', 'terrorism_premium', 'total_premium_collected']) }} as hashdiff,
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
    add_on_premium, base_premium, gross_premium, group_discount_amount, instalment_count, long_term_discount_amount, net_premium, terrorism_premium, total_premium_collected,
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
