{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_PARTY_GROUP_CENSUS
-- Parent: HUB_PARTY
-- Multi-active grain key: Member Reference
-- Source: {{ ref('int_health__sat_party_group_census') }}. No joins in THIS load.

with source_data as (

    select parent_bk, member_reference_ck, active_indicator, date_of_joining, designation_band, employee_id, location_reference, member_name, record_source
    from {{ ref('int_health__sat_party_group_census') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_PARTY'", 'parent_bk']) }} as party_hkey,
        parent_bk, member_reference_ck,
        active_indicator, date_of_joining, designation_band, employee_id, location_reference, member_name,
        record_source
    from source_data

),

hashed as (

    select
        party_hkey,
        member_reference_ck,
        active_indicator, date_of_joining, designation_band, employee_id, location_reference, member_name,
        {{ dbt_utils.generate_surrogate_key(['active_indicator', 'date_of_joining', 'designation_band', 'employee_id', 'location_reference', 'member_name']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by party_hkey, member_reference_ck, hashdiff
        order by record_source
    ) = 1

)

select
    party_hkey,
    member_reference_ck,
        active_indicator, date_of_joining, designation_band, employee_id, location_reference, member_name,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.party_hkey = d.party_hkey and t.member_reference_ck = d.member_reference_ck
      and t.hashdiff = d.hashdiff
)
{% endif %}
