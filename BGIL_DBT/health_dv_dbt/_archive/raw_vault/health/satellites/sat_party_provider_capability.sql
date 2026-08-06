{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_PARTY_PROVIDER_CAPABILITY
-- Parent: HUB_PARTY
-- Multi-active grain key: Facility Code
-- Source: {{ ref('int_health__sat_party_provider_capability') }}. No joins in THIS load.

with source_data as (

    select parent_bk, facility_code_ck, accreditation_indicator, accreditation_reference, available_indicator, capability_remarks, capacity, facility_category, facility_count, facility_name, record_source
    from {{ ref('int_health__sat_party_provider_capability') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_PARTY'", 'parent_bk']) }} as party_hkey,
        parent_bk, facility_code_ck,
        accreditation_indicator, accreditation_reference, available_indicator, capability_remarks, capacity, facility_category, facility_count, facility_name,
        record_source
    from source_data

),

hashed as (

    select
        party_hkey,
        facility_code_ck,
        accreditation_indicator, accreditation_reference, available_indicator, capability_remarks, capacity, facility_category, facility_count, facility_name,
        {{ dbt_utils.generate_surrogate_key(['accreditation_indicator', 'accreditation_reference', 'available_indicator', 'capability_remarks', 'capacity', 'facility_category', 'facility_count', 'facility_name']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by party_hkey, facility_code_ck, hashdiff
        order by record_source
    ) = 1

)

select
    party_hkey,
    facility_code_ck,
        accreditation_indicator, accreditation_reference, available_indicator, capability_remarks, capacity, facility_category, facility_count, facility_name,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.party_hkey = d.party_hkey and t.facility_code_ck = d.facility_code_ck
      and t.hashdiff = d.hashdiff
)
{% endif %}
