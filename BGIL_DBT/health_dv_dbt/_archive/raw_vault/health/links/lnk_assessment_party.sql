{{
    config(
        materialized='incremental',
        unique_key='assessment_party_hkey'
    )
}}

-- Link: LNK_ASSESSMENT_PARTY (Assessment Party) -- Associative
-- Associates the assessor (surveyor, doctor, underwriter, investigator) and subject party.
-- Source: {{ ref('int_health__lnk_assessment_party') }} (unions 10 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_assessment_party') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_ASSESSMENT'", 'assessment_bk']) }} as assessment_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_PARTY'", 'party_bk']) }} as party_hkey,
        assessment_bk, party_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_ASSESSMENT_PARTY'", 'assessment_hkey', 'party_hkey']) }} as assessment_party_hkey,
        assessment_hkey, assessment_bk, party_hkey, party_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by assessment_party_hkey order by record_source) = 1

)

select assessment_party_hkey, assessment_hkey, assessment_bk, party_hkey, party_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where assessment_party_hkey not in (select assessment_party_hkey from {{ this }})
{% endif %}
