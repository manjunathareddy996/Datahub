{{
    config(
        materialized='incremental',
        unique_key='claim_loss_event_hkey'
    )
}}

-- Link: LNK_CLAIM_LOSS_EVENT (Claim Loss Event) -- Transactional
-- Links a claim to the loss event that triggered it.
-- Source: {{ ref('int_health__lnk_claim_loss_event') }} (unions 3 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_claim_loss_event') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_CLAIM'", 'claim_bk']) }} as claim_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_LOSS_EVENT'", 'loss_event_bk']) }} as loss_event_hkey,
        claim_bk, loss_event_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_CLAIM_LOSS_EVENT'", 'claim_hkey', 'loss_event_hkey']) }} as claim_loss_event_hkey,
        claim_hkey, claim_bk, loss_event_hkey, loss_event_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by claim_loss_event_hkey order by record_source) = 1

)

select claim_loss_event_hkey, claim_hkey, claim_bk, loss_event_hkey, loss_event_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where claim_loss_event_hkey not in (select claim_loss_event_hkey from {{ this }})
{% endif %}
