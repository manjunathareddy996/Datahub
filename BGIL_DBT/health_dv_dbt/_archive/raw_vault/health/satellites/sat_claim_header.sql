{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_CLAIM_HEADER
-- Parent: HUB_CLAIM
-- Multi-active grain key: none (single-active)
-- Source: {{ ref('int_health__sat_claim_header') }}. No joins in THIS load.

with source_data as (

    select parent_bk, claim_category, claim_reference_number, claim_remarks, claim_status, claim_sub_status, claim_type, closed_date, gross_incurred_amount, net_incurred_amount, notification_date, registration_date, record_source
    from {{ ref('int_health__sat_claim_header') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_CLAIM'", 'parent_bk']) }} as claim_hkey,
        parent_bk,
        claim_category, claim_reference_number, claim_remarks, claim_status, claim_sub_status, claim_type, closed_date, gross_incurred_amount, net_incurred_amount, notification_date, registration_date,
        record_source
    from source_data

),

hashed as (

    select
        claim_hkey,
        claim_category, claim_reference_number, claim_remarks, claim_status, claim_sub_status, claim_type, closed_date, gross_incurred_amount, net_incurred_amount, notification_date, registration_date,
        {{ dbt_utils.generate_surrogate_key(['claim_category', 'claim_reference_number', 'claim_remarks', 'claim_status', 'claim_sub_status', 'claim_type', 'closed_date', 'gross_incurred_amount', 'net_incurred_amount', 'notification_date', 'registration_date']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by claim_hkey, hashdiff
        order by record_source
    ) = 1

)

select
    claim_hkey,
    claim_category, claim_reference_number, claim_remarks, claim_status, claim_sub_status, claim_type, closed_date, gross_incurred_amount, net_incurred_amount, notification_date, registration_date,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.claim_hkey = d.claim_hkey
      and t.hashdiff = d.hashdiff
)
{% endif %}
