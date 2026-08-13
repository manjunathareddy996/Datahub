{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_CLAIM_CO_RI_SHARE
-- Parent: HUB_CLAIM
-- Multi-active grain key: none (single-active)
-- Single contributing source table: no intermediate view created (collapsed). No joins in THIS load.

with source_data as (

    select parent_bk, co_insurance_our_share_amount, record_source
    from (
        select distinct
            claim_id as parent_bk,
            nullif(trim(to_varchar(amount)), '') as co_insurance_our_share_amount,
            'BJAZ_HM_COINSU_CLM_DTLS' as record_source
        from {{ ref('stg_health__bjaz_hm_coinsu_clm_dtls') }}
        where claim_id is not null
    )

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_CLAIM'", 'parent_bk']) }} as claim_hkey,
        parent_bk,
        co_insurance_our_share_amount,
        record_source
    from source_data

),

hashed as (

    select
        claim_hkey,
        co_insurance_our_share_amount,
        {{ dbt_utils.generate_surrogate_key(['co_insurance_our_share_amount']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by claim_hkey, hashdiff
        order by record_source
    ) = 1

)

select
    claim_hkey,
    co_insurance_our_share_amount,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.claim_hkey = d.claim_hkey
      and t.hashdiff = d.hashdiff
)
{% endif %}
