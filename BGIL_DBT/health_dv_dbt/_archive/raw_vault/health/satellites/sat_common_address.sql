{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_COMMON_ADDRESS
-- Parent: HUB_LOCATION
-- Multi-active grain key: none (single-active)
-- Source: {{ ref('int_health__sat_common_address') }}. No joins in THIS load.

with source_data as (

    select parent_bk, address_line_1, address_line_2, building_name, city, country_code, country_name, landmark, locality, post_office_name, postal_code, state_name, street_name, village, record_source
    from {{ ref('int_health__sat_common_address') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_LOCATION'", 'parent_bk']) }} as location_hkey,
        parent_bk,
        address_line_1, address_line_2, building_name, city, country_code, country_name, landmark, locality, post_office_name, postal_code, state_name, street_name, village,
        record_source
    from source_data

),

hashed as (

    select
        location_hkey,
        address_line_1, address_line_2, building_name, city, country_code, country_name, landmark, locality, post_office_name, postal_code, state_name, street_name, village,
        {{ dbt_utils.generate_surrogate_key(['address_line_1', 'address_line_2', 'building_name', 'city', 'country_code', 'country_name', 'landmark', 'locality', 'post_office_name', 'postal_code', 'state_name', 'street_name', 'village']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by location_hkey, hashdiff
        order by record_source
    ) = 1

)

select
    location_hkey,
    address_line_1, address_line_2, building_name, city, country_code, country_name, landmark, locality, post_office_name, postal_code, state_name, street_name, village,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.location_hkey = d.location_hkey
      and t.hashdiff = d.hashdiff
)
{% endif %}
