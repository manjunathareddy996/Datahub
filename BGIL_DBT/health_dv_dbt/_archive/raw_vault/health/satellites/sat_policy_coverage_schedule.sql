{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_POLICY_COVERAGE_SCHEDULE
-- Parent: HUB_POLICY
-- Multi-active grain key: Coverage Reference, Coverage Sequence
-- Source: {{ ref('int_health__sat_policy_coverage_schedule') }}. No joins in THIS load.

with source_data as (

    select parent_bk, coverage_reference_ck, coverage_sequence_ck, co_payment_amount, co_payment_percentage, coverage_opted_indicator, premium_for_coverage, sub_limit_amount, sum_insured, record_source
    from {{ ref('int_health__sat_policy_coverage_schedule') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_POLICY'", 'parent_bk']) }} as policy_hkey,
        parent_bk, coverage_reference_ck, coverage_sequence_ck,
        co_payment_amount, co_payment_percentage, coverage_opted_indicator, premium_for_coverage, sub_limit_amount, sum_insured,
        record_source
    from source_data

),

hashed as (

    select
        policy_hkey,
        coverage_reference_ck, coverage_sequence_ck,
        co_payment_amount, co_payment_percentage, coverage_opted_indicator, premium_for_coverage, sub_limit_amount, sum_insured,
        {{ dbt_utils.generate_surrogate_key(['co_payment_amount', 'co_payment_percentage', 'coverage_opted_indicator', 'premium_for_coverage', 'sub_limit_amount', 'sum_insured']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by policy_hkey, coverage_reference_ck, coverage_sequence_ck, hashdiff
        order by record_source
    ) = 1

)

select
    policy_hkey,
    coverage_reference_ck, coverage_sequence_ck,
        co_payment_amount, co_payment_percentage, coverage_opted_indicator, premium_for_coverage, sub_limit_amount, sum_insured,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.policy_hkey = d.policy_hkey and t.coverage_reference_ck = d.coverage_reference_ck and t.coverage_sequence_ck = d.coverage_sequence_ck
      and t.hashdiff = d.hashdiff
)
{% endif %}
