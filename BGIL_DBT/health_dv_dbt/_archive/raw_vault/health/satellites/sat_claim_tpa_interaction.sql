{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_CLAIM_TPA_INTERACTION
-- Parent: HUB_CLAIM
-- Multi-active grain key: none (single-active)
-- Source: {{ ref('int_health__sat_claim_tpa_interaction') }}. No joins in THIS load.

with source_data as (

    select parent_bk, authorisation_message, authorisation_remarks, bill_submission_date, claimed_package_amount, denial_reason, enhancement_amount, enhancement_request_indicator, final_authorisation_amount, pre_auth_amount, pre_auth_approved_date, pre_auth_request_date, tpa_reference, record_source
    from {{ ref('int_health__sat_claim_tpa_interaction') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_CLAIM'", 'parent_bk']) }} as claim_hkey,
        parent_bk,
        authorisation_message, authorisation_remarks, bill_submission_date, claimed_package_amount, denial_reason, enhancement_amount, enhancement_request_indicator, final_authorisation_amount, pre_auth_amount, pre_auth_approved_date, pre_auth_request_date, tpa_reference,
        record_source
    from source_data

),

hashed as (

    select
        claim_hkey,
        authorisation_message, authorisation_remarks, bill_submission_date, claimed_package_amount, denial_reason, enhancement_amount, enhancement_request_indicator, final_authorisation_amount, pre_auth_amount, pre_auth_approved_date, pre_auth_request_date, tpa_reference,
        {{ dbt_utils.generate_surrogate_key(['authorisation_message', 'authorisation_remarks', 'bill_submission_date', 'claimed_package_amount', 'denial_reason', 'enhancement_amount', 'enhancement_request_indicator', 'final_authorisation_amount', 'pre_auth_amount', 'pre_auth_approved_date', 'pre_auth_request_date', 'tpa_reference']) }} as hashdiff,
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
    authorisation_message, authorisation_remarks, bill_submission_date, claimed_package_amount, denial_reason, enhancement_amount, enhancement_request_indicator, final_authorisation_amount, pre_auth_amount, pre_auth_approved_date, pre_auth_request_date, tpa_reference,
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
