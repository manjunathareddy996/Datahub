{{
    config(
        materialized='incremental',
        unique_key='loss_event_location_hkey'
    )
}}

-- Link: LNK_LOSS_EVENT_LOCATION (Loss Event Location) -- Associative
-- Associates the place where a loss event occurred.
-- Source: {{ ref('int_health__lnk_loss_event_location') }} (unions 2 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_loss_event_location') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_LOCATION'", 'location_bk']) }} as location_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_LOSS_EVENT'", 'loss_event_bk']) }} as loss_event_hkey,
        location_bk, loss_event_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_LOSS_EVENT_LOCATION'", 'location_hkey', 'loss_event_hkey']) }} as loss_event_location_hkey,
        location_hkey, location_bk, loss_event_hkey, loss_event_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by loss_event_location_hkey order by record_source) = 1

)

select loss_event_location_hkey, location_hkey, location_bk, loss_event_hkey, loss_event_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where loss_event_location_hkey not in (select loss_event_location_hkey from {{ this }})
{% endif %}
