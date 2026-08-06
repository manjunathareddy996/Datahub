{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_PARTY_ADDRESS_USAGE
-- Parent: HUB_PARTY
-- Multi-active grain key: Address Usage Type, Sequence
-- Source: {{ ref('int_health__sat_party_address_usage') }}. No joins in THIS load.

with source_data as (

    select parent_bk, address_usage_type_ck, sequence_ck, address_line_1, address_line_2, city, postal_code, state_code, record_source
    from {{ ref('int_health__sat_party_address_usage') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_PARTY'", 'parent_bk']) }} as party_hkey,
        parent_bk, address_usage_type_ck, sequence_ck,
        address_line_1, address_line_2, city, postal_code, state_code,
        record_source
    from source_data

),

hashed as (

    select
        party_hkey,
        address_usage_type_ck, sequence_ck,
        address_line_1, address_line_2, city, postal_code, state_code,
        {{ dbt_utils.generate_surrogate_key(['address_line_1', 'address_line_2', 'city', 'postal_code', 'state_code']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by party_hkey, address_usage_type_ck, sequence_ck, hashdiff
        order by record_source
    ) = 1

)

select
    party_hkey,
    address_usage_type_ck, sequence_ck,
        address_line_1, address_line_2, city, postal_code, state_code,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.party_hkey = d.party_hkey and t.address_usage_type_ck = d.address_usage_type_ck and t.sequence_ck = d.sequence_ck
      and t.hashdiff = d.hashdiff
)
{% endif %}
