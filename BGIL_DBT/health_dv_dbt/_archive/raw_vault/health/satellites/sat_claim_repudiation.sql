{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_CLAIM_REPUDIATION
-- Parent: HUB_CLAIM
-- Multi-active grain key: none (single-active)
-- Source: {{ ref('int_health__sat_claim_repudiation') }}. No joins in THIS load.

with source_data as (

    select parent_bk, repudiation_date, repudiation_reason, record_source
    from {{ ref('int_health__sat_claim_repudiation') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_CLAIM'", 'parent_bk']) }} as claim_hkey,
        parent_bk,
        repudiation_date, repudiation_reason,
        record_source
    from source_data

),

hashed as (

    select
        claim_hkey,
        repudiation_date, repudiation_reason,
        {{ dbt_utils.generate_surrogate_key(['repudiation_date', 'repudiation_reason']) }} as hashdiff,
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
    repudiation_date, repudiation_reason,
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
