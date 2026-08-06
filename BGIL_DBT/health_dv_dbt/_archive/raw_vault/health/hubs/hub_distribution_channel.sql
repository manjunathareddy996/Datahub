{{
    config(
        materialized='incremental',
        unique_key='distribution_channel_hkey'
    )
}}

-- Hub: HUB_DISTRIBUTION_CHANNEL (Distribution Channel)
-- Business key: Distribution Channel Identifier
-- Source: {{ ref('int_health__hub_distribution_channel') }} (unions 90 contributing tables).
-- Hash key is namespaced with the hub code, so this hub's hkey can never collide with another
-- hub's hkey even where both are sourced from literally the same raw column value (e.g.
-- HUB_QUOTE and HUB_PROPOSAL both keyed by QUOTE_REF_NO on some Health tables).
-- This load does no joins.

with source_data as (

    select * from {{ ref('int_health__hub_distribution_channel') }}

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_DISTRIBUTION_CHANNEL'", 'business_key']) }} as distribution_channel_hkey,
        business_key as distribution_channel_bk,
        record_source,
        current_timestamp() as load_dts
    from source_data

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by distribution_channel_hkey order by record_source) = 1

)

select distribution_channel_hkey, distribution_channel_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where distribution_channel_hkey not in (select distribution_channel_hkey from {{ this }})
{% endif %}
