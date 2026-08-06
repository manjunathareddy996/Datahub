{{
    config(
        materialized='incremental',
        unique_key='channel_org_unit_hkey'
    )
}}

-- Link: LNK_CHANNEL_ORG_UNIT (Channel Managed By Org Unit) -- Hierarchical
-- Links a distribution channel to the internal unit that manages it.
-- Source: {{ ref('int_health__lnk_channel_org_unit') }} (unions 12 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_channel_org_unit') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_DISTRIBUTION_CHANNEL'", 'distribution_channel_bk']) }} as distribution_channel_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_ORG_UNIT'", 'org_unit_bk']) }} as org_unit_hkey,
        distribution_channel_bk, org_unit_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_CHANNEL_ORG_UNIT'", 'distribution_channel_hkey', 'org_unit_hkey']) }} as channel_org_unit_hkey,
        distribution_channel_hkey, distribution_channel_bk, org_unit_hkey, org_unit_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by channel_org_unit_hkey order by record_source) = 1

)

select channel_org_unit_hkey, distribution_channel_hkey, distribution_channel_bk, org_unit_hkey, org_unit_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where channel_org_unit_hkey not in (select channel_org_unit_hkey from {{ this }})
{% endif %}
