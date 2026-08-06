{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_CASE_HEADER
-- Parent: HUB_CASE
-- Multi-active grain key: none (single-active)
-- Single contributing source table: no intermediate view created (collapsed). No joins in THIS load.

with source_data as (

    select parent_bk, assigned_to_reference, case_status, record_source
    from (
        select distinct
            allocate_id as parent_bk,
            nullif(trim(to_varchar(allocate_to)), '') as assigned_to_reference,
            nullif(trim(to_varchar(bucket_status)), '') as case_status,
            'BJAZ_HM_INWARD_AUTOALLOCATION' as record_source
        from {{ ref('stg_health__bjaz_hm_inward_autoallocation') }}
        where allocate_id is not null
    )

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_CASE'", 'parent_bk']) }} as case_hkey,
        parent_bk,
        assigned_to_reference, case_status,
        record_source
    from source_data

),

hashed as (

    select
        case_hkey,
        assigned_to_reference, case_status,
        {{ dbt_utils.generate_surrogate_key(['assigned_to_reference', 'case_status']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by case_hkey, hashdiff
        order by record_source
    ) = 1

)

select
    case_hkey,
    assigned_to_reference, case_status,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.case_hkey = d.case_hkey
      and t.hashdiff = d.hashdiff
)
{% endif %}
