{{
    config(
        materialized='incremental',
        unique_key='quote_proposal_hkey'
    )
}}

-- Link: LNK_QUOTE_PROPOSAL (Quote to Proposal) -- Transactional
-- Traces conversion of a quote into a formal proposal.
-- Source: {{ ref('int_health__lnk_quote_proposal') }} (unions 2 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_quote_proposal') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_PROPOSAL'", 'proposal_bk']) }} as proposal_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_QUOTE'", 'quote_bk']) }} as quote_hkey,
        proposal_bk, quote_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_QUOTE_PROPOSAL'", 'proposal_hkey', 'quote_hkey']) }} as quote_proposal_hkey,
        proposal_hkey, proposal_bk, quote_hkey, quote_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by quote_proposal_hkey order by record_source) = 1

)

select quote_proposal_hkey, proposal_hkey, proposal_bk, quote_hkey, quote_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where quote_proposal_hkey not in (select quote_proposal_hkey from {{ this }})
{% endif %}
