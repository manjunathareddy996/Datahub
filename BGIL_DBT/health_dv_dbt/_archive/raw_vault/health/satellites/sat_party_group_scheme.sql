{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_PARTY_GROUP_SCHEME
-- Parent: HUB_PARTY
-- Multi-active grain key: none (single-active)
-- Single contributing source table: no intermediate view created (collapsed). No joins in THIS load.

with source_data as (

    select parent_bk, scheme_name, record_source
    from (
        select distinct
            ldr_pid as parent_bk,
            nullif(trim(to_varchar(group_name)), '') as scheme_name,
            'BJAZ_HM_COINSU_CLM_DTLS' as record_source
        from {{ ref('stg_health__bjaz_hm_coinsu_clm_dtls') }}
        where ldr_pid is not null
    )

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_PARTY'", 'parent_bk']) }} as party_hkey,
        parent_bk,
        scheme_name,
        record_source
    from source_data

),

hashed as (

    select
        party_hkey,
        scheme_name,
        {{ dbt_utils.generate_surrogate_key(['scheme_name']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by party_hkey, hashdiff
        order by record_source
    ) = 1

)

select
    party_hkey,
    scheme_name,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.party_hkey = d.party_hkey
      and t.hashdiff = d.hashdiff
)
{% endif %}
