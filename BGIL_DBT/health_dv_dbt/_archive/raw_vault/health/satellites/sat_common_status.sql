{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_COMMON_STATUS
-- RE-ANCHORED (mapper-confirmed, not the canonical model default): parent is HUB_POLICY in the canonical model; built against HUB_PARTY here because that is the key this table's row actually carries.
-- Parent: HUB_PARTY
-- Multi-active grain key: none (single-active)
-- Single contributing source table: no intermediate view created (collapsed). No joins in THIS load.

with source_data as (

    select parent_bk, status_code, record_source
    from (
        select distinct
            hosid as parent_bk,
            nullif(trim(to_varchar(hos_status)), '') as status_code,
            'BJAZ_HM_HOSPITAL_MASTER' as record_source
        from {{ ref('stg_health__bjaz_hm_hospital_master') }}
        where hosid is not null
    )

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_PARTY'", 'parent_bk']) }} as party_hkey,
        parent_bk,
        status_code,
        record_source
    from source_data

),

hashed as (

    select
        party_hkey,
        status_code,
        {{ dbt_utils.generate_surrogate_key(['status_code']) }} as hashdiff,
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
    status_code,
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
