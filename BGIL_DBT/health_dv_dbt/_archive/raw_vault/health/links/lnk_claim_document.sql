{{
    config(
        materialized='incremental',
        unique_key='claim_document_hkey'
    )
}}

-- Link: LNK_CLAIM_DOCUMENT (Claim Document) -- Associative
-- Associates claim forms, bills, FIR, discharge vouchers with a claim.
-- Source: {{ ref('int_health__lnk_claim_document') }} (unions 8 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_claim_document') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_CLAIM'", 'claim_bk']) }} as claim_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_DOCUMENT'", 'document_bk']) }} as document_hkey,
        claim_bk, document_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_CLAIM_DOCUMENT'", 'claim_hkey', 'document_hkey']) }} as claim_document_hkey,
        claim_hkey, claim_bk, document_hkey, document_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by claim_document_hkey order by record_source) = 1

)

select claim_document_hkey, claim_hkey, claim_bk, document_hkey, document_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where claim_document_hkey not in (select claim_document_hkey from {{ this }})
{% endif %}
