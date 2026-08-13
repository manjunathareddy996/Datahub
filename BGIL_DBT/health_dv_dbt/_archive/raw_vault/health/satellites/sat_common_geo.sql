{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_COMMON_GEO
-- Parent: HUB_LOCATION
-- Multi-active grain key: none (single-active)
-- Single contributing source table: no intermediate view created (collapsed). No joins in THIS load.

with source_data as (

    select parent_bk, latitude, longitude, region_name, zone_code, record_source
    from (
        select distinct
            location_code as parent_bk,
            cast(null as varchar) as latitude,
            cast(null as varchar) as longitude,
            nullif(trim(to_varchar(geo_area)), '') as region_name,
            cast(null as varchar) as zone_code,
            'BJAZ_HM_INWARD_DTLS' as record_source
        from {{ ref('stg_health__bjaz_hm_inward_dtls') }}
        where location_code is not null
    )

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_LOCATION'", 'parent_bk']) }} as location_hkey,
        parent_bk,
        latitude, longitude, region_name, zone_code,
        record_source
    from source_data

),

hashed as (

    select
        location_hkey,
        latitude, longitude, region_name, zone_code,
        {{ dbt_utils.generate_surrogate_key(['latitude', 'longitude', 'region_name', 'zone_code']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by location_hkey, hashdiff
        order by record_source
    ) = 1

)

select
    location_hkey,
    latitude, longitude, region_name, zone_code,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.location_hkey = d.location_hkey
      and t.hashdiff = d.hashdiff
)
{% endif %}
