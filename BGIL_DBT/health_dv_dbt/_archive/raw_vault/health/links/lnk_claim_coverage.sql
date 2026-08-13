{{
    config(
        materialized='incremental',
        unique_key='claim_coverage_hkey'
    )
}}

-- Link: LNK_CLAIM_COVERAGE (Claim Coverage) -- Associative
-- Associates the coverages/heads of damage invoked by a claim.
-- Source: {{ ref('int_health__lnk_claim_coverage') }} (unions 2 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_claim_coverage') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_CLAIM'", 'claim_bk']) }} as claim_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_COVERAGE'", 'coverage_bk']) }} as coverage_hkey,
        claim_bk, coverage_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_CLAIM_COVERAGE'", 'claim_hkey', 'coverage_hkey']) }} as claim_coverage_hkey,
        claim_hkey, claim_bk, coverage_hkey, coverage_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by claim_coverage_hkey order by record_source) = 1

)

select claim_coverage_hkey, claim_hkey, claim_bk, coverage_hkey, coverage_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where claim_coverage_hkey not in (select claim_coverage_hkey from {{ this }})
{% endif %}
