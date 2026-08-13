{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_POLICY_HEADER
-- Parent: HUB_POLICY
-- Multi-active grain key: none (single-active)
-- Source: {{ ref('int_health__sat_policy_header') }}. No joins in THIS load.

with source_data as (

    select parent_bk, cover_note_date, cover_note_reference, first_year_indicator, issue_date, master_policy_reference, policy_number, policy_remarks, policy_status, policy_term, policy_term_days, policy_type, premium_payer_reference, risk_expiry_date, risk_inception_date, risk_start_time, sum_insured_basis, sum_insured_total, top_up_policy_indicator, record_source
    from {{ ref('int_health__sat_policy_header') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_POLICY'", 'parent_bk']) }} as policy_hkey,
        parent_bk,
        cover_note_date, cover_note_reference, first_year_indicator, issue_date, master_policy_reference, policy_number, policy_remarks, policy_status, policy_term, policy_term_days, policy_type, premium_payer_reference, risk_expiry_date, risk_inception_date, risk_start_time, sum_insured_basis, sum_insured_total, top_up_policy_indicator,
        record_source
    from source_data

),

hashed as (

    select
        policy_hkey,
        cover_note_date, cover_note_reference, first_year_indicator, issue_date, master_policy_reference, policy_number, policy_remarks, policy_status, policy_term, policy_term_days, policy_type, premium_payer_reference, risk_expiry_date, risk_inception_date, risk_start_time, sum_insured_basis, sum_insured_total, top_up_policy_indicator,
        {{ dbt_utils.generate_surrogate_key(['cover_note_date', 'cover_note_reference', 'first_year_indicator', 'issue_date', 'master_policy_reference', 'policy_number', 'policy_remarks', 'policy_status', 'policy_term', 'policy_term_days', 'policy_type', 'premium_payer_reference', 'risk_expiry_date', 'risk_inception_date', 'risk_start_time', 'sum_insured_basis', 'sum_insured_total', 'top_up_policy_indicator']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by policy_hkey, hashdiff
        order by record_source
    ) = 1

)

select
    policy_hkey,
    cover_note_date, cover_note_reference, first_year_indicator, issue_date, master_policy_reference, policy_number, policy_remarks, policy_status, policy_term, policy_term_days, policy_type, premium_payer_reference, risk_expiry_date, risk_inception_date, risk_start_time, sum_insured_basis, sum_insured_total, top_up_policy_indicator,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.policy_hkey = d.policy_hkey
      and t.hashdiff = d.hashdiff
)
{% endif %}
