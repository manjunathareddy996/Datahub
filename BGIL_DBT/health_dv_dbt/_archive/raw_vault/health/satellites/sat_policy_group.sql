{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_POLICY_GROUP
-- Parent: HUB_POLICY
-- Multi-active grain key: none (single-active)
-- Source: {{ ref('int_health__sat_policy_group') }}. No joins in THIS load.

with source_data as (

    select parent_bk, contributory_indicator, employer_contribution_percentage, floater_indicator, group_size, group_type, master_policy_number, member_count, record_source
    from {{ ref('int_health__sat_policy_group') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_POLICY'", 'parent_bk']) }} as policy_hkey,
        parent_bk,
        contributory_indicator, employer_contribution_percentage, floater_indicator, group_size, group_type, master_policy_number, member_count,
        record_source
    from source_data

),

hashed as (

    select
        policy_hkey,
        contributory_indicator, employer_contribution_percentage, floater_indicator, group_size, group_type, master_policy_number, member_count,
        {{ dbt_utils.generate_surrogate_key(['contributory_indicator', 'employer_contribution_percentage', 'floater_indicator', 'group_size', 'group_type', 'master_policy_number', 'member_count']) }} as hashdiff,
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
    contributory_indicator, employer_contribution_percentage, floater_indicator, group_size, group_type, master_policy_number, member_count,
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
