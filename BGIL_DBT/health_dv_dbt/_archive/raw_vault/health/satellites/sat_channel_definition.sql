{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_CHANNEL_DEFINITION
-- Parent: HUB_DISTRIBUTION_CHANNEL
-- Multi-active grain key: none (single-active)
-- Source: {{ ref('int_health__sat_channel_definition') }}. No joins in THIS load.

with source_data as (

    select parent_bk, channel_category, channel_name, channel_type, sub_channel_code, record_source
    from {{ ref('int_health__sat_channel_definition') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_DISTRIBUTION_CHANNEL'", 'parent_bk']) }} as distribution_channel_hkey,
        parent_bk,
        channel_category, channel_name, channel_type, sub_channel_code,
        record_source
    from source_data

),

hashed as (

    select
        distribution_channel_hkey,
        channel_category, channel_name, channel_type, sub_channel_code,
        {{ dbt_utils.generate_surrogate_key(['channel_category', 'channel_name', 'channel_type', 'sub_channel_code']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by distribution_channel_hkey, hashdiff
        order by record_source
    ) = 1

)

select
    distribution_channel_hkey,
    channel_category, channel_name, channel_type, sub_channel_code,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.distribution_channel_hkey = d.distribution_channel_hkey
      and t.hashdiff = d.hashdiff
)
{% endif %}
