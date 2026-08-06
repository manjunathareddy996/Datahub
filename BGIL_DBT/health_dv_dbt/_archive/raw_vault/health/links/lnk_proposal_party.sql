{{
    config(
        materialized='incremental',
        unique_key='proposal_party_hkey'
    )
}}

-- Link: LNK_PROPOSAL_PARTY (Proposal Party) -- Associative
-- Associates proposer, insured, intermediary and nominee with a proposal.
-- Source: {{ ref('int_health__lnk_proposal_party') }} (unions 11 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_proposal_party') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_PARTY'", 'party_bk']) }} as party_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_PROPOSAL'", 'proposal_bk']) }} as proposal_hkey,
        party_bk, proposal_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_PROPOSAL_PARTY'", 'party_hkey', 'proposal_hkey']) }} as proposal_party_hkey,
        party_hkey, party_bk, proposal_hkey, proposal_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by proposal_party_hkey order by record_source) = 1

)

select proposal_party_hkey, party_hkey, party_bk, proposal_hkey, proposal_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where proposal_party_hkey not in (select proposal_party_hkey from {{ this }})
{% endif %}
