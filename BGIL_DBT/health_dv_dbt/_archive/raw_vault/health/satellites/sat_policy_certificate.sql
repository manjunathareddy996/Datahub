{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_POLICY_CERTIFICATE
-- Parent: HUB_POLICY
-- Multi-active grain key: Certificate Number
-- Source: {{ ref('int_health__sat_policy_certificate') }}. No joins in THIS load.

with source_data as (

    select parent_bk, certificate_number_ck, certificate_number, coverage_end_date, coverage_start_date, enrolment_date, exit_reason, member_premium, member_status, relationship_to_primary, record_source
    from {{ ref('int_health__sat_policy_certificate') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_POLICY'", 'parent_bk']) }} as policy_hkey,
        parent_bk, certificate_number_ck,
        certificate_number, coverage_end_date, coverage_start_date, enrolment_date, exit_reason, member_premium, member_status, relationship_to_primary,
        record_source
    from source_data

),

hashed as (

    select
        policy_hkey,
        certificate_number_ck,
        certificate_number, coverage_end_date, coverage_start_date, enrolment_date, exit_reason, member_premium, member_status, relationship_to_primary,
        {{ dbt_utils.generate_surrogate_key(['certificate_number', 'coverage_end_date', 'coverage_start_date', 'enrolment_date', 'exit_reason', 'member_premium', 'member_status', 'relationship_to_primary']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by policy_hkey, certificate_number_ck, hashdiff
        order by record_source
    ) = 1

)

select
    policy_hkey,
    certificate_number_ck,
        certificate_number, coverage_end_date, coverage_start_date, enrolment_date, exit_reason, member_premium, member_status, relationship_to_primary,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.policy_hkey = d.policy_hkey and t.certificate_number_ck = d.certificate_number_ck
      and t.hashdiff = d.hashdiff
)
{% endif %}
