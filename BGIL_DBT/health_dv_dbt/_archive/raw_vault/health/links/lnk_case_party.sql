{{
    config(
        materialized='incremental',
        unique_key='case_party_hkey'
    )
}}

-- Link: LNK_CASE_PARTY (Case Party) -- Associative
-- Associates complainant, handler, investigator and respondents with a case.
-- Source: {{ ref('int_health__lnk_case_party') }} (unions 3 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_case_party') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_CASE'", 'case_bk']) }} as case_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_PARTY'", 'party_bk']) }} as party_hkey,
        case_bk, party_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_CASE_PARTY'", 'case_hkey', 'party_hkey']) }} as case_party_hkey,
        case_hkey, case_bk, party_hkey, party_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by case_party_hkey order by record_source) = 1

)

select case_party_hkey, case_hkey, case_bk, party_hkey, party_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where case_party_hkey not in (select case_party_hkey from {{ this }})
{% endif %}
