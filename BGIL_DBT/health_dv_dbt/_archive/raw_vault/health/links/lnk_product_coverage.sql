{{
    config(
        materialized='incremental',
        unique_key='product_coverage_hkey'
    )
}}

-- Link: LNK_PRODUCT_COVERAGE (Product Coverage) -- Associative
-- Associates coverages, benefits, riders, add-ons and exclusions with a product.
-- Source: {{ ref('int_health__lnk_product_coverage') }} (unions 3 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_product_coverage') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_COVERAGE'", 'coverage_bk']) }} as coverage_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_PRODUCT'", 'product_bk']) }} as product_hkey,
        coverage_bk, product_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_PRODUCT_COVERAGE'", 'coverage_hkey', 'product_hkey']) }} as product_coverage_hkey,
        coverage_hkey, coverage_bk, product_hkey, product_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by product_coverage_hkey order by record_source) = 1

)

select product_coverage_hkey, coverage_hkey, coverage_bk, product_hkey, product_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where product_coverage_hkey not in (select product_coverage_hkey from {{ this }})
{% endif %}
