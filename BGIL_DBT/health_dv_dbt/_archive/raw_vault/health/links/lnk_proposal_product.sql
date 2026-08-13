{{
    config(
        materialized='incremental',
        unique_key='proposal_product_hkey'
    )
}}

-- Link: LNK_PROPOSAL_PRODUCT (Proposal Product) -- Associative
-- Associates the proposed product with a proposal.
-- Source: {{ ref('int_health__lnk_proposal_product') }} (unions 10 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_proposal_product') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_PRODUCT'", 'product_bk']) }} as product_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_PROPOSAL'", 'proposal_bk']) }} as proposal_hkey,
        product_bk, proposal_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_PROPOSAL_PRODUCT'", 'product_hkey', 'proposal_hkey']) }} as proposal_product_hkey,
        product_hkey, product_bk, proposal_hkey, proposal_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by proposal_product_hkey order by record_source) = 1

)

select proposal_product_hkey, product_hkey, product_bk, proposal_hkey, proposal_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where proposal_product_hkey not in (select proposal_product_hkey from {{ this }})
{% endif %}
