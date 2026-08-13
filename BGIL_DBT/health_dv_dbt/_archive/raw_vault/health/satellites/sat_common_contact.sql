{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_COMMON_CONTACT
-- Parent: HUB_PARTY
-- Multi-active grain key: Contact Point Type, Contact Priority Order
-- Source: {{ ref('int_health__sat_common_contact') }}. No joins in THIS load.

with source_data as (

    select parent_bk, contact_point_type_ck, contact_priority_order_ck, alternate_email_address, alternate_mobile_number, email_address, fax_number, landline_number, mobile_number, std_code, record_source
    from {{ ref('int_health__sat_common_contact') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_PARTY'", 'parent_bk']) }} as party_hkey,
        parent_bk, contact_point_type_ck, contact_priority_order_ck,
        alternate_email_address, alternate_mobile_number, email_address, fax_number, landline_number, mobile_number, std_code,
        record_source
    from source_data

),

hashed as (

    select
        party_hkey,
        contact_point_type_ck, contact_priority_order_ck,
        alternate_email_address, alternate_mobile_number, email_address, fax_number, landline_number, mobile_number, std_code,
        {{ dbt_utils.generate_surrogate_key(['alternate_email_address', 'alternate_mobile_number', 'email_address', 'fax_number', 'landline_number', 'mobile_number', 'std_code']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by party_hkey, contact_point_type_ck, contact_priority_order_ck, hashdiff
        order by record_source
    ) = 1

)

select
    party_hkey,
    contact_point_type_ck, contact_priority_order_ck,
        alternate_email_address, alternate_mobile_number, email_address, fax_number, landline_number, mobile_number, std_code,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.party_hkey = d.party_hkey and t.contact_point_type_ck = d.contact_point_type_ck and t.contact_priority_order_ck = d.contact_priority_order_ck
      and t.hashdiff = d.hashdiff
)
{% endif %}
