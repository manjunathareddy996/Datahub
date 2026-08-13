{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_PROPOSAL_QUESTIONNAIRE
-- Parent: HUB_PROPOSAL
-- Multi-active grain key: Question Code
-- Source: {{ ref('int_health__sat_proposal_questionnaire') }}. No joins in THIS load.

with source_data as (

    select parent_bk, question_code_ck, response_value, record_source
    from {{ ref('int_health__sat_proposal_questionnaire') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_PROPOSAL'", 'parent_bk']) }} as proposal_hkey,
        parent_bk, question_code_ck,
        response_value,
        record_source
    from source_data

),

hashed as (

    select
        proposal_hkey,
        question_code_ck,
        response_value,
        {{ dbt_utils.generate_surrogate_key(['response_value']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by proposal_hkey, question_code_ck, hashdiff
        order by record_source
    ) = 1

)

select
    proposal_hkey,
    question_code_ck,
        response_value,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.proposal_hkey = d.proposal_hkey and t.question_code_ck = d.question_code_ck
      and t.hashdiff = d.hashdiff
)
{% endif %}
