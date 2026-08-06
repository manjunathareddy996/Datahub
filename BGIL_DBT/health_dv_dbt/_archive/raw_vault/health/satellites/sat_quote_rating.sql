{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_QUOTE_RATING
-- Parent: HUB_QUOTE
-- Multi-active grain key: none (single-active)
-- Single contributing source table: no intermediate view created (collapsed). No joins in THIS load.

with source_data as (

    select parent_bk, discount_amount, gross_premium, total_annual_premium, record_source
    from (
        select distinct
            quote_sub_no as parent_bk,
            nullif(trim(to_varchar(ho_discount)), '') as discount_amount,
            nullif(trim(to_varchar(prem_quoted)), '') as gross_premium,
            nullif(trim(to_varchar(discounted_premium)), '') as total_annual_premium,
            'BJAZ_GRP_HLT_DTLS' as record_source
        from {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
        where quote_sub_no is not null
    )

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_QUOTE'", 'parent_bk']) }} as quote_hkey,
        parent_bk,
        discount_amount, gross_premium, total_annual_premium,
        record_source
    from source_data

),

hashed as (

    select
        quote_hkey,
        discount_amount, gross_premium, total_annual_premium,
        {{ dbt_utils.generate_surrogate_key(['discount_amount', 'gross_premium', 'total_annual_premium']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by quote_hkey, hashdiff
        order by record_source
    ) = 1

)

select
    quote_hkey,
    discount_amount, gross_premium, total_annual_premium,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.quote_hkey = d.quote_hkey
      and t.hashdiff = d.hashdiff
)
{% endif %}
