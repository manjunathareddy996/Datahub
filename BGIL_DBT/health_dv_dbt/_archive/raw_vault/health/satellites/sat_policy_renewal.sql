{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_POLICY_RENEWAL
-- Parent: HUB_POLICY
-- Multi-active grain key: none (single-active)
-- Single contributing source table: no intermediate view created (collapsed). No joins in THIS load.

with source_data as (

    select parent_bk, preceding_policy_reference, record_source
    from (
        select distinct
            reg_no as parent_bk,
            nullif(trim(to_varchar(prev_pol_ref)), '') as preceding_policy_reference,
            'BJAZ_GRP_HLT_DTLS' as record_source
        from {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
        where reg_no is not null
    )

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_POLICY'", 'parent_bk']) }} as policy_hkey,
        parent_bk,
        preceding_policy_reference,
        record_source
    from source_data

),

hashed as (

    select
        policy_hkey,
        preceding_policy_reference,
        {{ dbt_utils.generate_surrogate_key(['preceding_policy_reference']) }} as hashdiff,
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
    preceding_policy_reference,
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
