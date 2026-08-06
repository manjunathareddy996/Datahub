{{
    config(
        materialized='incremental',
        unique_key='product_variant_hkey'
    )
}}

-- Link: LNK_PRODUCT_VARIANT (Product Variant) -- Hierarchical
-- Relates a product variant to its base product.
-- Source: {{ ref('int_health__lnk_product_variant') }} (unions 3 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_product_variant') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_PRODUCT'", 'product_from_bk']) }} as product_from_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_PRODUCT'", 'product_to_bk']) }} as product_to_hkey,
        product_from_bk, product_to_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_PRODUCT_VARIANT'", 'product_from_hkey', 'product_to_hkey']) }} as product_variant_hkey,
        product_from_hkey, product_from_bk, product_to_hkey, product_to_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by product_variant_hkey order by record_source) = 1

)

select product_variant_hkey, product_from_hkey, product_from_bk, product_to_hkey, product_to_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where product_variant_hkey not in (select product_variant_hkey from {{ this }})
{% endif %}
