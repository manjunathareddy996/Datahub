{{
    config(
        materialized='incremental',
        unique_key='proposal_policy_hkey'
    )
}}

-- Link: LNK_PROPOSAL_POLICY (Proposal to Policy) -- Transactional
-- Traces issuance of a policy from an accepted proposal.
-- Source: {{ ref('int_health__lnk_proposal_policy') }} (unions 11 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_proposal_policy') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_POLICY'", 'policy_bk']) }} as policy_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_PROPOSAL'", 'proposal_bk']) }} as proposal_hkey,
        policy_bk, proposal_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_PROPOSAL_POLICY'", 'policy_hkey', 'proposal_hkey']) }} as proposal_policy_hkey,
        policy_hkey, policy_bk, proposal_hkey, proposal_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by proposal_policy_hkey order by record_source) = 1

)

select proposal_policy_hkey, policy_hkey, policy_bk, proposal_hkey, proposal_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where proposal_policy_hkey not in (select proposal_policy_hkey from {{ this }})
{% endif %}
