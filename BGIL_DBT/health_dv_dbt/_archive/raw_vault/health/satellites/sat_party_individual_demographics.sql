{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS
-- Parent: HUB_PARTY
-- Multi-active grain key: none (single-active)
-- Source: {{ ref('int_health__sat_shared__common_consent_party_individual_demographics') }} (SHARED with sibling satellite(s)). No joins in THIS load.

with source_data as (

    select parent_bk, marital_status, occupation_description, record_source
    from {{ ref('int_health__sat_shared__common_consent_party_individual_demographics') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_PARTY'", 'parent_bk']) }} as party_hkey,
        parent_bk,
        marital_status, occupation_description,
        record_source
    from source_data

),

hashed as (

    select
        party_hkey,
        marital_status, occupation_description,
        {{ dbt_utils.generate_surrogate_key(['marital_status', 'occupation_description']) }} as hashdiff,
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
    marital_status, occupation_description,
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
