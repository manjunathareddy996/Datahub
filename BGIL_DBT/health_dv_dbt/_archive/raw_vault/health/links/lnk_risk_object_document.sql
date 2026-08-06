{{
    config(
        materialized='incremental',
        unique_key='risk_object_document_hkey'
    )
}}

-- Link: LNK_RISK_OBJECT_DOCUMENT (Risk Object Document) -- Associative
-- Associates RC, invoice, valuation and inspection documents with a risk object.
-- Single contributing source table: no intermediate view created (collapsed).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select document_bk, risk_object_bk, record_source
    from (
    select distinct
        medical_report as document_bk,
        contract_id || '|' || member_no as risk_object_bk,
        'BJAZ_EC_MEM_DTLS_EXTN' as record_source
    from {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
    where medical_report is not null and contract_id is not null and member_no is not null
    )

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_DOCUMENT'", 'document_bk']) }} as document_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_RISK_OBJECT'", 'risk_object_bk']) }} as risk_object_hkey,
        document_bk, risk_object_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_RISK_OBJECT_DOCUMENT'", 'document_hkey', 'risk_object_hkey']) }} as risk_object_document_hkey,
        document_hkey, document_bk, risk_object_hkey, risk_object_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by risk_object_document_hkey order by record_source) = 1

)

select risk_object_document_hkey, document_hkey, document_bk, risk_object_hkey, risk_object_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where risk_object_document_hkey not in (select risk_object_document_hkey from {{ this }})
{% endif %}
