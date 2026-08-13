{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_LOSS_EVENT_DETAIL
-- Parent: HUB_LOSS_EVENT
-- Multi-active grain key: none (single-active)
-- Source: {{ ref('int_health__sat_loss_event_detail') }}. No joins in THIS load.

with source_data as (

    select parent_bk, loss_date, loss_event_type, record_source
    from {{ ref('int_health__sat_loss_event_detail') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_LOSS_EVENT'", 'parent_bk']) }} as loss_event_hkey,
        parent_bk,
        loss_date, loss_event_type,
        record_source
    from source_data

),

hashed as (

    select
        loss_event_hkey,
        loss_date, loss_event_type,
        {{ dbt_utils.generate_surrogate_key(['loss_date', 'loss_event_type']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by loss_event_hkey, hashdiff
        order by record_source
    ) = 1

)

select
    loss_event_hkey,
    loss_date, loss_event_type,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.loss_event_hkey = d.loss_event_hkey
      and t.hashdiff = d.hashdiff
)
{% endif %}
