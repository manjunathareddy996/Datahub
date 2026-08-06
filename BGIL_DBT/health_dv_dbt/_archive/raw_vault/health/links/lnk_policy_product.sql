{{
    config(
        materialized='incremental',
        unique_key='policy_product_hkey'
    )
}}

-- Link: LNK_POLICY_PRODUCT (Policy Product) -- Associative
-- Associates the underwritten product with a policy.
-- Source: {{ ref('int_health__lnk_policy_product') }} (unions 37 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_policy_product') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_POLICY'", 'policy_bk']) }} as policy_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_PRODUCT'", 'product_bk']) }} as product_hkey,
        policy_bk, product_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_POLICY_PRODUCT'", 'policy_hkey', 'product_hkey']) }} as policy_product_hkey,
        policy_hkey, policy_bk, product_hkey, product_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by policy_product_hkey order by record_source) = 1

)

select policy_product_hkey, policy_hkey, policy_bk, product_hkey, product_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where policy_product_hkey not in (select policy_product_hkey from {{ this }})
{% endif %}
