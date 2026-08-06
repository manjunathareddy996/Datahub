{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_LOCATION_PROFILE
-- Parent: HUB_LOCATION
-- Multi-active grain key: none (single-active)
-- Single contributing source table: no intermediate view created (collapsed). No joins in THIS load.

with source_data as (

    select parent_bk, location_name, record_source
    from (
        select distinct
            policy_location as parent_bk,
            nullif(trim(to_varchar(policy_location)), '') as location_name,
            'BJAZ_HM_HCM_EXTRACT' as record_source
        from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
        where policy_location is not null
    )

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_LOCATION'", 'parent_bk']) }} as location_hkey,
        parent_bk,
        location_name,
        record_source
    from source_data

),

hashed as (

    select
        location_hkey,
        location_name,
        {{ dbt_utils.generate_surrogate_key(['location_name']) }} as hashdiff,
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
    location_name,
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
