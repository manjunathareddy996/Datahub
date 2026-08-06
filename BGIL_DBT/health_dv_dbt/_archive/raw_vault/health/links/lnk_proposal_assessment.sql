{{
    config(
        materialized='incremental',
        unique_key='proposal_assessment_hkey'
    )
}}

-- Link: LNK_PROPOSAL_ASSESSMENT (Proposal Assessment) -- Transactional
-- Links underwriting assessments/surveys/medicals performed for a proposal.
-- Source: {{ ref('int_health__lnk_proposal_assessment') }} (unions 3 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_proposal_assessment') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_ASSESSMENT'", 'assessment_bk']) }} as assessment_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_PROPOSAL'", 'proposal_bk']) }} as proposal_hkey,
        assessment_bk, proposal_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_PROPOSAL_ASSESSMENT'", 'assessment_hkey', 'proposal_hkey']) }} as proposal_assessment_hkey,
        assessment_hkey, assessment_bk, proposal_hkey, proposal_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by proposal_assessment_hkey order by record_source) = 1

)

select proposal_assessment_hkey, assessment_hkey, assessment_bk, proposal_hkey, proposal_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where proposal_assessment_hkey not in (select proposal_assessment_hkey from {{ this }})
{% endif %}
