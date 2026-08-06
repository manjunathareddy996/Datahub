{{
    config(
        materialized='incremental',
        unique_key='claim_policy_hkey'
    )
}}

-- Link: LNK_CLAIM_POLICY (Claim Policy) -- Transactional
-- Links a claim to the policy under which it is made.
-- Source: {{ ref('int_health__lnk_claim_policy') }} (unions 14 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_claim_policy') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_CLAIM'", 'claim_bk']) }} as claim_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_POLICY'", 'policy_bk']) }} as policy_hkey,
        claim_bk, policy_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_CLAIM_POLICY'", 'claim_hkey', 'policy_hkey']) }} as claim_policy_hkey,
        claim_hkey, claim_bk, policy_hkey, policy_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by claim_policy_hkey order by record_source) = 1

)

select claim_policy_hkey, claim_hkey, claim_bk, policy_hkey, policy_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where claim_policy_hkey not in (select claim_policy_hkey from {{ this }})
{% endif %}
