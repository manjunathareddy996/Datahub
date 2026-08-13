{{
    config(
        materialized='incremental',
        unique_key='agreement_document_hkey'
    )
}}

-- Link: LNK_AGREEMENT_DOCUMENT (Agreement Document) -- Associative
-- Associates contract documents with an agreement.
-- Single contributing source table: no intermediate view created (collapsed).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select agreement_bk, document_bk, record_source
    from (
    select distinct
        remedinet_provider_code as agreement_bk,
        omni_inward_no as document_bk,
        'BJAZ_REMEDINET_CLAIM_DETAILS' as record_source
    from {{ ref('stg_health__bjaz_remedinet_claim_details') }}
    where remedinet_provider_code is not null and omni_inward_no is not null
    )

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_AGREEMENT'", 'agreement_bk']) }} as agreement_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_DOCUMENT'", 'document_bk']) }} as document_hkey,
        agreement_bk, document_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_AGREEMENT_DOCUMENT'", 'agreement_hkey', 'document_hkey']) }} as agreement_document_hkey,
        agreement_hkey, agreement_bk, document_hkey, document_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by agreement_document_hkey order by record_source) = 1

)

select agreement_document_hkey, agreement_hkey, agreement_bk, document_hkey, document_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where agreement_document_hkey not in (select agreement_document_hkey from {{ this }})
{% endif %}
