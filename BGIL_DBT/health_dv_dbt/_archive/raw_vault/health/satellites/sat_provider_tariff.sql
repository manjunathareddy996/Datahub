{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_PROVIDER_TARIFF
-- Parent: HUB_PARTY
-- Multi-active grain key: Service Code
-- Source: {{ ref('int_health__sat_provider_tariff') }}. No joins in THIS load.

with source_data as (

    select parent_bk, service_code_ck, discount_percentage, effective_date, expiry_date, package_rate, room_rent_cap, service_description, record_source
    from {{ ref('int_health__sat_provider_tariff') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_PARTY'", 'parent_bk']) }} as party_hkey,
        parent_bk, service_code_ck,
        discount_percentage, effective_date, expiry_date, package_rate, room_rent_cap, service_description,
        record_source
    from source_data

),

hashed as (

    select
        party_hkey,
        service_code_ck,
        discount_percentage, effective_date, expiry_date, package_rate, room_rent_cap, service_description,
        {{ dbt_utils.generate_surrogate_key(['discount_percentage', 'effective_date', 'expiry_date', 'package_rate', 'room_rent_cap', 'service_description']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by party_hkey, service_code_ck, hashdiff
        order by record_source
    ) = 1

)

select
    party_hkey,
    service_code_ck,
        discount_percentage, effective_date, expiry_date, package_rate, room_rent_cap, service_description,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.party_hkey = d.party_hkey and t.service_code_ck = d.service_code_ck
      and t.hashdiff = d.hashdiff
)
{% endif %}
