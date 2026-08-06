{{
    config(
        materialized='incremental',
        unique_key='claim_case_hkey'
    )
}}

-- Link: LNK_CLAIM_CASE (Claim Case) -- Associative
-- Associates investigation, litigation and grievance cases with a claim.
-- Source: {{ ref('int_health__lnk_claim_case') }} (unions 3 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_claim_case') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_CASE'", 'case_bk']) }} as case_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_CLAIM'", 'claim_bk']) }} as claim_hkey,
        case_bk, claim_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_CLAIM_CASE'", 'case_hkey', 'claim_hkey']) }} as claim_case_hkey,
        case_hkey, case_bk, claim_hkey, claim_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by claim_case_hkey order by record_source) = 1

)

select claim_case_hkey, case_hkey, case_bk, claim_hkey, claim_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where claim_case_hkey not in (select claim_case_hkey from {{ this }})
{% endif %}
