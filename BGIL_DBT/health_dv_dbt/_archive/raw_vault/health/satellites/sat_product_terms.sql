{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_PRODUCT_TERMS
-- Parent: HUB_PRODUCT
-- Multi-active grain key: none (single-active)
-- Source: {{ ref('int_health__sat_product_terms') }}. No joins in THIS load.

with source_data as (

    select parent_bk, family_definition, record_source
    from {{ ref('int_health__sat_product_terms') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_PRODUCT'", 'parent_bk']) }} as product_hkey,
        parent_bk,
        family_definition,
        record_source
    from source_data

),

hashed as (

    select
        product_hkey,
        family_definition,
        {{ dbt_utils.generate_surrogate_key(['family_definition']) }} as hashdiff,
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
    family_definition,
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
