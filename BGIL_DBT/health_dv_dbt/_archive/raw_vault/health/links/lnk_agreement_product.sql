{{
    config(
        materialized='incremental',
        unique_key='agreement_product_hkey'
    )
}}

-- Link: LNK_AGREEMENT_PRODUCT (Agreement Product Scope) -- Associative
-- Scopes an intermediary/bancassurance agreement to the products it authorises.
-- Single contributing source table: no intermediate view created (collapsed).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select agreement_bk, product_bk, record_source
    from (
    select distinct
        deal_id as agreement_bk,
        product_code as product_bk,
        'BJAZ_HEALTH_WEBSERVICE_INFO' as record_source
    from {{ ref('stg_health__bjaz_health_webservice_info') }}
    where deal_id is not null and product_code is not null
    )

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_AGREEMENT'", 'agreement_bk']) }} as agreement_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_PRODUCT'", 'product_bk']) }} as product_hkey,
        agreement_bk, product_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_AGREEMENT_PRODUCT'", 'agreement_hkey', 'product_hkey']) }} as agreement_product_hkey,
        agreement_hkey, agreement_bk, product_hkey, product_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by agreement_product_hkey order by record_source) = 1

)

select agreement_product_hkey, agreement_hkey, agreement_bk, product_hkey, product_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where agreement_product_hkey not in (select agreement_product_hkey from {{ this }})
{% endif %}
