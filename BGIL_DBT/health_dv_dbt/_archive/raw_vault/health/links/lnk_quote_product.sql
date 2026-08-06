{{
    config(
        materialized='incremental',
        unique_key='quote_product_hkey'
    )
}}

-- Link: LNK_QUOTE_PRODUCT (Quote Product) -- Associative
-- Associates a quote with the quoted product.
-- Source: {{ ref('int_health__lnk_quote_product') }} (unions 7 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_quote_product') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_PRODUCT'", 'product_bk']) }} as product_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_QUOTE'", 'quote_bk']) }} as quote_hkey,
        product_bk, quote_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_QUOTE_PRODUCT'", 'product_hkey', 'quote_hkey']) }} as quote_product_hkey,
        product_hkey, product_bk, quote_hkey, quote_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by quote_product_hkey order by record_source) = 1

)

select quote_product_hkey, product_hkey, product_bk, quote_hkey, quote_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where quote_product_hkey not in (select quote_product_hkey from {{ this }})
{% endif %}
