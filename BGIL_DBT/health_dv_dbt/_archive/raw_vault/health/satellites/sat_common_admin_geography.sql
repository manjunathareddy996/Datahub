{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_COMMON_ADMIN_GEOGRAPHY
-- RE-ANCHORED (mapper-confirmed, not the canonical model default): parent is HUB_LOCATION in the canonical model; built against HUB_PARTY here because that is the key this table's row actually carries.
-- Parent: HUB_PARTY
-- Multi-active grain key: none (single-active)
-- Source: {{ ref('int_health__sat_shared__common_admin_geography_party_organisation_profile_provider_quality') }} (SHARED with sibling satellite(s)). No joins in THIS load.

with source_data as (

    select parent_bk, city_class_code, record_source
    from {{ ref('int_health__sat_shared__common_admin_geography_party_organisation_profile_provider_quality') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_PARTY'", 'parent_bk']) }} as party_hkey,
        parent_bk,
        city_class_code,
        record_source
    from source_data

),

hashed as (

    select
        party_hkey,
        city_class_code,
        {{ dbt_utils.generate_surrogate_key(['city_class_code']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by party_hkey, hashdiff
        order by record_source
    ) = 1

)

select
    party_hkey,
    city_class_code,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.party_hkey = d.party_hkey
      and t.hashdiff = d.hashdiff
)
{% endif %}
