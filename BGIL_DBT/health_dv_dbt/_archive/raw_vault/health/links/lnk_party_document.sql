{{
    config(
        materialized='incremental',
        unique_key='party_document_hkey'
    )
}}

-- Link: LNK_PARTY_DOCUMENT (Party Document) -- Associative
-- Associates KYC and other documents with a party.
-- Source: {{ ref('int_health__lnk_party_document') }} (unions 9 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_party_document') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_DOCUMENT'", 'document_bk']) }} as document_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_PARTY'", 'party_bk']) }} as party_hkey,
        document_bk, party_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_PARTY_DOCUMENT'", 'document_hkey', 'party_hkey']) }} as party_document_hkey,
        document_hkey, document_bk, party_hkey, party_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by party_document_hkey order by record_source) = 1

)

select party_document_hkey, document_hkey, document_bk, party_hkey, party_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where party_document_hkey not in (select party_document_hkey from {{ this }})
{% endif %}
