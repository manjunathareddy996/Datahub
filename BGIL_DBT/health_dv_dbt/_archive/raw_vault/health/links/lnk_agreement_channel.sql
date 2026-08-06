{{
    config(
        materialized='incremental',
        unique_key='agreement_channel_hkey'
    )
}}

-- Link: LNK_AGREEMENT_CHANNEL (Agreement Channel) -- Associative
-- Links an appointment/tie-up agreement to the channel it enables.
-- Source: {{ ref('int_health__lnk_agreement_channel') }} (unions 3 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_agreement_channel') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_AGREEMENT'", 'agreement_bk']) }} as agreement_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_DISTRIBUTION_CHANNEL'", 'distribution_channel_bk']) }} as distribution_channel_hkey,
        agreement_bk, distribution_channel_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_AGREEMENT_CHANNEL'", 'agreement_hkey', 'distribution_channel_hkey']) }} as agreement_channel_hkey,
        agreement_hkey, agreement_bk, distribution_channel_hkey, distribution_channel_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by agreement_channel_hkey order by record_source) = 1

)

select agreement_channel_hkey, agreement_hkey, agreement_bk, distribution_channel_hkey, distribution_channel_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where agreement_channel_hkey not in (select agreement_channel_hkey from {{ this }})
{% endif %}
