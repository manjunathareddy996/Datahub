{{
    config(
        materialized='incremental',
        unique_key='loss_event_hkey'
    )
}}

-- Hub: HUB_LOSS_EVENT (Loss Event)
-- Business key: Loss Event Identifier
-- Source: {{ ref('int_health__hub_loss_event') }} (unions 3 contributing tables).
-- Hash key is namespaced with the hub code, so this hub's hkey can never collide with another
-- hub's hkey even where both are sourced from literally the same raw column value (e.g.
-- HUB_QUOTE and HUB_PROPOSAL both keyed by QUOTE_REF_NO on some Health tables).
-- This load does no joins.

with source_data as (

    select * from {{ ref('int_health__hub_loss_event') }}

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_LOSS_EVENT'", 'business_key']) }} as loss_event_hkey,
        business_key as loss_event_bk,
        record_source,
        current_timestamp() as load_dts
    from source_data

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by loss_event_hkey order by record_source) = 1

)

select loss_event_hkey, loss_event_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where loss_event_hkey not in (select loss_event_hkey from {{ this }})
{% endif %}
