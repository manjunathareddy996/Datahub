{{
    config(
        materialized='incremental',
        unique_key='treaty_product_hkey'
    )
}}

-- Link: LNK_TREATY_PRODUCT (Treaty Product) -- Associative
-- Scopes the products / lines of business covered by a treaty.
-- Single contributing source table: no intermediate view created (collapsed).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select product_bk, reinsurance_treaty_bk, record_source
    from (
    select distinct
        product_code as product_bk,
        re_insu as reinsurance_treaty_bk,
        'BJAZ_GPG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
    where product_code is not null and re_insu is not null
    )

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_PRODUCT'", 'product_bk']) }} as product_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_REINSURANCE_TREATY'", 'reinsurance_treaty_bk']) }} as reinsurance_treaty_hkey,
        product_bk, reinsurance_treaty_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_TREATY_PRODUCT'", 'product_hkey', 'reinsurance_treaty_hkey']) }} as treaty_product_hkey,
        product_hkey, product_bk, reinsurance_treaty_hkey, reinsurance_treaty_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by treaty_product_hkey order by record_source) = 1

)

select treaty_product_hkey, product_hkey, product_bk, reinsurance_treaty_hkey, reinsurance_treaty_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where treaty_product_hkey not in (select treaty_product_hkey from {{ this }})
{% endif %}
