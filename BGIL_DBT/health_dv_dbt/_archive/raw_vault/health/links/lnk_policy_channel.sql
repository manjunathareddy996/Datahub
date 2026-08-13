{{
    config(
        materialized='incremental',
        unique_key='policy_channel_hkey'
    )
}}

-- Link: LNK_POLICY_CHANNEL (Policy Channel) -- Associative
-- Associates the selling distribution channel with a policy.
-- Source: {{ ref('int_health__lnk_policy_channel') }} (unions 43 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_policy_channel') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_DISTRIBUTION_CHANNEL'", 'distribution_channel_bk']) }} as distribution_channel_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_POLICY'", 'policy_bk']) }} as policy_hkey,
        distribution_channel_bk, policy_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_POLICY_CHANNEL'", 'distribution_channel_hkey', 'policy_hkey']) }} as policy_channel_hkey,
        distribution_channel_hkey, distribution_channel_bk, policy_hkey, policy_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by policy_channel_hkey order by record_source) = 1

)

select policy_channel_hkey, distribution_channel_hkey, distribution_channel_bk, policy_hkey, policy_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where policy_channel_hkey not in (select policy_channel_hkey from {{ this }})
{% endif %}
