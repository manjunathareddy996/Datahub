{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_PARTY_CORRESPONDENCE
-- RE-ANCHORED (mapper-confirmed, not the canonical model default): parent is HUB_PARTY in the canonical model; built against HUB_CLAIM here because that is the key this table's row actually carries.
-- Parent: HUB_CLAIM
-- Multi-active grain key: none (single-active)
-- Single contributing source table: no intermediate view created (collapsed). No joins in THIS load.

with source_data as (

    select parent_bk, channel, record_source
    from (
        select distinct
            claim_id as parent_bk,
            nullif(trim(to_varchar(mode_of_dispatch)), '') as channel,
            'BJAZ_HM_OUTWARD_DTLS' as record_source
        from {{ ref('stg_health__bjaz_hm_outward_dtls') }}
        where claim_id is not null
    )

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_CLAIM'", 'parent_bk']) }} as claim_hkey,
        parent_bk,
        channel,
        record_source
    from source_data

),

hashed as (

    select
        claim_hkey,
        channel,
        {{ dbt_utils.generate_surrogate_key(['channel']) }} as hashdiff,
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
    channel,
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
