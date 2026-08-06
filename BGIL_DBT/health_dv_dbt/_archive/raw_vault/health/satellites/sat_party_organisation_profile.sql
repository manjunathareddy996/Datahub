{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_PARTY_ORGANISATION_PROFILE
-- Parent: HUB_PARTY
-- Multi-active grain key: none (single-active)
-- Source: {{ ref('int_health__sat_shared__common_admin_geography_party_organisation_profile_provider_quality') }} (SHARED with sibling satellite(s)). No joins in THIS load.

with source_data as (

    select parent_bk, industry_description, legal_constitution_code, msme_indicator, record_source
    from {{ ref('int_health__sat_shared__common_admin_geography_party_organisation_profile_provider_quality') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_PARTY'", 'parent_bk']) }} as party_hkey,
        parent_bk,
        industry_description, legal_constitution_code, msme_indicator,
        record_source
    from source_data

),

hashed as (

    select
        party_hkey,
        industry_description, legal_constitution_code, msme_indicator,
        {{ dbt_utils.generate_surrogate_key(['industry_description', 'legal_constitution_code', 'msme_indicator']) }} as hashdiff,
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
    industry_description, legal_constitution_code, msme_indicator,
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
