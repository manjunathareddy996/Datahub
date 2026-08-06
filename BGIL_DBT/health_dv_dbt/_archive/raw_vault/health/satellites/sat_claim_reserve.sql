{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_CLAIM_RESERVE
-- Parent: HUB_CLAIM
-- Multi-active grain key: Reserve Head
-- Source: {{ ref('int_health__sat_claim_reserve') }}. No joins in THIS load.

with source_data as (

    select parent_bk, reserve_head_ck, current_reserve_amount, record_source
    from {{ ref('int_health__sat_claim_reserve') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_CLAIM'", 'parent_bk']) }} as claim_hkey,
        parent_bk, reserve_head_ck,
        current_reserve_amount,
        record_source
    from source_data

),

hashed as (

    select
        claim_hkey,
        reserve_head_ck,
        current_reserve_amount,
        {{ dbt_utils.generate_surrogate_key(['current_reserve_amount']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by claim_hkey, reserve_head_ck, hashdiff
        order by record_source
    ) = 1

)

select
    claim_hkey,
    reserve_head_ck,
        current_reserve_amount,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.claim_hkey = d.claim_hkey and t.reserve_head_ck = d.reserve_head_ck
      and t.hashdiff = d.hashdiff
)
{% endif %}
