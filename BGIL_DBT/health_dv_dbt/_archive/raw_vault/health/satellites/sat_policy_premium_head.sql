{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_POLICY_PREMIUM_HEAD
-- Parent: HUB_POLICY
-- Multi-active grain key: Premium Head Code
-- Source: {{ ref('int_health__sat_policy_premium_head') }}. No joins in THIS load.

with source_data as (

    select parent_bk, premium_head_code_ck, base_amount, net_head_premium, premium_basis, record_source
    from {{ ref('int_health__sat_policy_premium_head') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_POLICY'", 'parent_bk']) }} as policy_hkey,
        parent_bk, premium_head_code_ck,
        base_amount, net_head_premium, premium_basis,
        record_source
    from source_data

),

hashed as (

    select
        policy_hkey,
        premium_head_code_ck,
        base_amount, net_head_premium, premium_basis,
        {{ dbt_utils.generate_surrogate_key(['base_amount', 'net_head_premium', 'premium_basis']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by policy_hkey, premium_head_code_ck, hashdiff
        order by record_source
    ) = 1

)

select
    policy_hkey,
    premium_head_code_ck,
        base_amount, net_head_premium, premium_basis,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.policy_hkey = d.policy_hkey and t.premium_head_code_ck = d.premium_head_code_ck
      and t.hashdiff = d.hashdiff
)
{% endif %}
