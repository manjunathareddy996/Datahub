{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_POLICY_COINSURANCE
-- Parent: HUB_POLICY
-- Multi-active grain key: none (single-active)
-- Single contributing source table: no intermediate view created (collapsed). No joins in THIS load.

with source_data as (

    select parent_bk, co_insurance_reference_number, record_source
    from (
        select distinct
            policy_ref as parent_bk,
            nullif(trim(to_varchar(insurco_policy_no)), '') as co_insurance_reference_number,
            'BJAZ_HM_COINSU_CLM_DTLS' as record_source
        from {{ ref('stg_health__bjaz_hm_coinsu_clm_dtls') }}
        where policy_ref is not null
    )

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_POLICY'", 'parent_bk']) }} as policy_hkey,
        parent_bk,
        co_insurance_reference_number,
        record_source
    from source_data

),

hashed as (

    select
        policy_hkey,
        co_insurance_reference_number,
        {{ dbt_utils.generate_surrogate_key(['co_insurance_reference_number']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by policy_hkey, hashdiff
        order by record_source
    ) = 1

)

select
    policy_hkey,
    co_insurance_reference_number,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.policy_hkey = d.policy_hkey
      and t.hashdiff = d.hashdiff
)
{% endif %}
