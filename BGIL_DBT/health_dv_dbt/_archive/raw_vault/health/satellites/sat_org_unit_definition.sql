{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_ORG_UNIT_DEFINITION
-- Parent: HUB_ORG_UNIT
-- Multi-active grain key: none (single-active)
-- Single contributing source table: no intermediate view created (collapsed). No joins in THIS load.

with source_data as (

    select parent_bk, org_unit_code, org_unit_name, zone_name, record_source
    from (
        select distinct
            operating_office as parent_bk,
            nullif(trim(to_varchar(operating_code)), '') as org_unit_code,
            nullif(trim(to_varchar(operating_office)), '') as org_unit_name,
            cast(null as varchar) as zone_name,
            'BJAZ_TPA_CLAIM_DETAILS_WS' as record_source
        from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
        where operating_office is not null
    )

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_ORG_UNIT'", 'parent_bk']) }} as org_unit_hkey,
        parent_bk,
        org_unit_code, org_unit_name, zone_name,
        record_source
    from source_data

),

hashed as (

    select
        org_unit_hkey,
        org_unit_code, org_unit_name, zone_name,
        {{ dbt_utils.generate_surrogate_key(['org_unit_code', 'org_unit_name', 'zone_name']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by org_unit_hkey, hashdiff
        order by record_source
    ) = 1

)

select
    org_unit_hkey,
    org_unit_code, org_unit_name, zone_name,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.org_unit_hkey = d.org_unit_hkey
      and t.hashdiff = d.hashdiff
)
{% endif %}
