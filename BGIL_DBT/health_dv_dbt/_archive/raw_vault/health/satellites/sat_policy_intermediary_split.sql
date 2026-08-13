{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_POLICY_INTERMEDIARY_SPLIT
-- Parent: HUB_POLICY
-- Multi-active grain key: Intermediary Reference
-- Single contributing source table: no intermediate view created (collapsed). No joins in THIS load.

with source_data as (

    select parent_bk, intermediary_reference_ck, intermediary_reference, record_source
    from (
        select distinct
            pmasterpolicynumber as parent_bk,
            nullif(trim(to_varchar(intermediary)), '') as intermediary_reference_ck,
            nullif(trim(to_varchar(intermediary)), '') as intermediary_reference,
            'BJAZ_GENERIC_LOADER_LOG_TABLE' as record_source
        from {{ ref('stg_health__bjaz_generic_loader_log_table') }}
        where pmasterpolicynumber is not null
    )

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_POLICY'", 'parent_bk']) }} as policy_hkey,
        parent_bk, intermediary_reference_ck,
        intermediary_reference,
        record_source
    from source_data

),

hashed as (

    select
        policy_hkey,
        intermediary_reference_ck,
        intermediary_reference,
        {{ dbt_utils.generate_surrogate_key(['intermediary_reference']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by policy_hkey, intermediary_reference_ck, hashdiff
        order by record_source
    ) = 1

)

select
    policy_hkey,
    intermediary_reference_ck,
        intermediary_reference,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.policy_hkey = d.policy_hkey and t.intermediary_reference_ck = d.intermediary_reference_ck
      and t.hashdiff = d.hashdiff
)
{% endif %}
