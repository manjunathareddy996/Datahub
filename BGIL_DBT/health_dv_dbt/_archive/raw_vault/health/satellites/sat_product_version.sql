{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_PRODUCT_VERSION
-- Parent: HUB_PRODUCT
-- Multi-active grain key: none (single-active)
-- Single contributing source table: no intermediate view created (collapsed). No joins in THIS load.

with source_data as (

    select parent_bk, version_effective_date, record_source
    from (
        select distinct
            product_code as parent_bk,
            nullif(trim(to_varchar(effective_dt)), '') as version_effective_date,
            'BJAZ_HCS_PLANSI_MAPP' as record_source
        from {{ ref('stg_health__bjaz_hcs_plansi_mapp') }}
        where product_code is not null
    )

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_PRODUCT'", 'parent_bk']) }} as product_hkey,
        parent_bk,
        version_effective_date,
        record_source
    from source_data

),

hashed as (

    select
        product_hkey,
        version_effective_date,
        {{ dbt_utils.generate_surrogate_key(['version_effective_date']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by product_hkey, hashdiff
        order by record_source
    ) = 1

)

select
    product_hkey,
    version_effective_date,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.product_hkey = d.product_hkey
      and t.hashdiff = d.hashdiff
)
{% endif %}
