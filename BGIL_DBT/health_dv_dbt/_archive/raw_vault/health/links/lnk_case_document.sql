{{
    config(
        materialized='incremental',
        unique_key='case_document_hkey'
    )
}}

-- Link: LNK_CASE_DOCUMENT (Case Document) -- Associative
-- Associates correspondence and evidence documents with a case.
-- Source: {{ ref('int_health__lnk_case_document') }} (unions 3 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_case_document') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_CASE'", 'case_bk']) }} as case_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_DOCUMENT'", 'document_bk']) }} as document_hkey,
        case_bk, document_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_CASE_DOCUMENT'", 'case_hkey', 'document_hkey']) }} as case_document_hkey,
        case_hkey, case_bk, document_hkey, document_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by case_document_hkey order by record_source) = 1

)

select case_document_hkey, case_hkey, case_bk, document_hkey, document_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where case_document_hkey not in (select case_document_hkey from {{ this }})
{% endif %}
