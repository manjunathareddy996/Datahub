{{
    config(
        materialized='incremental',
        unique_key='policy_coverage_hkey'
    )
}}

-- Link: LNK_POLICY_COVERAGE (Policy Coverage) -- Associative
-- The coverage schedule - associates each coverage/rider/add-on granted under a policy.
-- Source: {{ ref('int_health__lnk_policy_coverage') }} (unions 6 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_policy_coverage') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_COVERAGE'", 'coverage_bk']) }} as coverage_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_POLICY'", 'policy_bk']) }} as policy_hkey,
        coverage_bk, policy_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_POLICY_COVERAGE'", 'coverage_hkey', 'policy_hkey']) }} as policy_coverage_hkey,
        coverage_hkey, coverage_bk, policy_hkey, policy_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by policy_coverage_hkey order by record_source) = 1

)

select policy_coverage_hkey, coverage_hkey, coverage_bk, policy_hkey, policy_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where policy_coverage_hkey not in (select policy_coverage_hkey from {{ this }})
{% endif %}
