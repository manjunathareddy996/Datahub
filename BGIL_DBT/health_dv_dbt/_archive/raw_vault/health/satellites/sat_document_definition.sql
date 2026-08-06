{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_DOCUMENT_DEFINITION
-- Parent: HUB_DOCUMENT
-- Multi-active grain key: none (single-active)
-- Source: {{ ref('int_health__sat_document_definition') }}. No joins in THIS load.

with source_data as (

    select parent_bk, document_category, document_name, document_reference_number, document_status, document_type, expiry_date, received_date, storage_reference, record_source
    from {{ ref('int_health__sat_document_definition') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_DOCUMENT'", 'parent_bk']) }} as document_hkey,
        parent_bk,
        document_category, document_name, document_reference_number, document_status, document_type, expiry_date, received_date, storage_reference,
        record_source
    from source_data

),

hashed as (

    select
        document_hkey,
        document_category, document_name, document_reference_number, document_status, document_type, expiry_date, received_date, storage_reference,
        {{ dbt_utils.generate_surrogate_key(['document_category', 'document_name', 'document_reference_number', 'document_status', 'document_type', 'expiry_date', 'received_date', 'storage_reference']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by document_hkey, hashdiff
        order by record_source
    ) = 1

)

select
    document_hkey,
    document_category, document_name, document_reference_number, document_status, document_type, expiry_date, received_date, storage_reference,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.document_hkey = d.document_hkey
      and t.hashdiff = d.hashdiff
)
{% endif %}
