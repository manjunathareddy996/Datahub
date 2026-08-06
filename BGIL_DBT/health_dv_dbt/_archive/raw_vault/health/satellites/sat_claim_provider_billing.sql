{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_CLAIM_PROVIDER_BILLING
-- Parent: HUB_CLAIM
-- Multi-active grain key: Bill Number
-- Source: {{ ref('int_health__sat_claim_provider_billing') }}. No joins in THIS load.

with source_data as (

    select parent_bk, bill_number_ck, approved_amount, authorised_amount, bill_date, bill_number, bill_status_type, bill_type, billed_amount, disallowance_reason, disallowed_amount, record_source
    from {{ ref('int_health__sat_claim_provider_billing') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_CLAIM'", 'parent_bk']) }} as claim_hkey,
        parent_bk, bill_number_ck,
        approved_amount, authorised_amount, bill_date, bill_number, bill_status_type, bill_type, billed_amount, disallowance_reason, disallowed_amount,
        record_source
    from source_data

),

hashed as (

    select
        claim_hkey,
        bill_number_ck,
        approved_amount, authorised_amount, bill_date, bill_number, bill_status_type, bill_type, billed_amount, disallowance_reason, disallowed_amount,
        {{ dbt_utils.generate_surrogate_key(['approved_amount', 'authorised_amount', 'bill_date', 'bill_number', 'bill_status_type', 'bill_type', 'billed_amount', 'disallowance_reason', 'disallowed_amount']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by claim_hkey, bill_number_ck, hashdiff
        order by record_source
    ) = 1

)

select
    claim_hkey,
    bill_number_ck,
        approved_amount, authorised_amount, bill_date, bill_number, bill_status_type, bill_type, billed_amount, disallowance_reason, disallowed_amount,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.claim_hkey = d.claim_hkey and t.bill_number_ck = d.bill_number_ck
      and t.hashdiff = d.hashdiff
)
{% endif %}
