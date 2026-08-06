{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_CLAIM_DISBURSEMENT_BATCH
-- Parent: HUB_CLAIM
-- Multi-active grain key: none (single-active)
-- Source: {{ ref('int_health__sat_shared__claim_disbursement_batch_claim_fnol') }} (SHARED with sibling satellite(s)). No joins in THIS load.

with source_data as (

    select parent_bk, batch_date, batch_reference, record_source
    from {{ ref('int_health__sat_shared__claim_disbursement_batch_claim_fnol') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_CLAIM'", 'parent_bk']) }} as claim_hkey,
        parent_bk,
        batch_date, batch_reference,
        record_source
    from source_data

),

hashed as (

    select
        claim_hkey,
        batch_date, batch_reference,
        {{ dbt_utils.generate_surrogate_key(['batch_date', 'batch_reference']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by claim_hkey, hashdiff
        order by record_source
    ) = 1

)

select
    claim_hkey,
    batch_date, batch_reference,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.claim_hkey = d.claim_hkey
      and t.hashdiff = d.hashdiff
)
{% endif %}
