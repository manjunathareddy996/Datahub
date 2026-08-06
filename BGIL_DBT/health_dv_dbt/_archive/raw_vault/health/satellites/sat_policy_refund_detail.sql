{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_POLICY_REFUND_DETAIL
-- Parent: HUB_POLICY
-- Multi-active grain key: none (single-active)
-- Single contributing source table: no intermediate view created (collapsed). No joins in THIS load.

with source_data as (

    select parent_bk, net_refund_amount, record_source
    from (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(refund_premium)), '') as net_refund_amount,
            'BJAZ_HM_MEMBER_DTLS' as record_source
        from {{ ref('stg_health__bjaz_hm_member_dtls') }}
        where contract_id is not null
    )

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_POLICY'", 'parent_bk']) }} as policy_hkey,
        parent_bk,
        net_refund_amount,
        record_source
    from source_data

),

hashed as (

    select
        policy_hkey,
        net_refund_amount,
        {{ dbt_utils.generate_surrogate_key(['net_refund_amount']) }} as hashdiff,
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
    net_refund_amount,
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
