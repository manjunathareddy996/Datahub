{{
    config(
        materialized='incremental',
        unique_key='agreement_hkey'
    )
}}

-- Hub: HUB_AGREEMENT (Agreement)
-- Business key: Agreement Identifier
-- Source: {{ ref('int_health__hub_agreement') }} (unions 5 contributing tables).
-- Hash key is namespaced with the hub code, so this hub's hkey can never collide with another
-- hub's hkey even where both are sourced from literally the same raw column value (e.g.
-- HUB_QUOTE and HUB_PROPOSAL both keyed by QUOTE_REF_NO on some Health tables).
-- This load does no joins.

with source_data as (

    select * from {{ ref('int_health__hub_agreement') }}

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_AGREEMENT'", 'business_key']) }} as agreement_hkey,
        business_key as agreement_bk,
        record_source,
        current_timestamp() as load_dts
    from source_data

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by agreement_hkey order by record_source) = 1

)

select agreement_hkey, agreement_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where agreement_hkey not in (select agreement_hkey from {{ this }})
{% endif %}
