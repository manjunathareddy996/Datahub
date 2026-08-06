{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_POLICY_DISCOUNT_LOADING_APPLIED
-- Parent: HUB_POLICY
-- Multi-active grain key: Item Code
-- Source: {{ ref('int_health__sat_policy_discount_loading_applied') }}. No joins in THIS load.

with source_data as (

    select parent_bk, item_code_ck, amount_applied, percentage_applied, record_source
    from {{ ref('int_health__sat_policy_discount_loading_applied') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_POLICY'", 'parent_bk']) }} as policy_hkey,
        parent_bk, item_code_ck,
        amount_applied, percentage_applied,
        record_source
    from source_data

),

hashed as (

    select
        policy_hkey,
        item_code_ck,
        amount_applied, percentage_applied,
        {{ dbt_utils.generate_surrogate_key(['amount_applied', 'percentage_applied']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by policy_hkey, item_code_ck, hashdiff
        order by record_source
    ) = 1

)

select
    policy_hkey,
    item_code_ck,
        amount_applied, percentage_applied,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.policy_hkey = d.policy_hkey and t.item_code_ck = d.item_code_ck
      and t.hashdiff = d.hashdiff
)
{% endif %}
