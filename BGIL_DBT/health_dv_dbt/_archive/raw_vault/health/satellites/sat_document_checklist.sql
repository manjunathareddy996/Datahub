{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_DOCUMENT_CHECKLIST
-- Parent: HUB_DOCUMENT
-- Multi-active grain key: Required Document Type
-- Source: {{ ref('int_health__sat_document_checklist') }}. No joins in THIS load.

with source_data as (

    select parent_bk, required_document_type_ck, received_indicator, required_document_type, record_source
    from {{ ref('int_health__sat_document_checklist') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_DOCUMENT'", 'parent_bk']) }} as document_hkey,
        parent_bk, required_document_type_ck,
        received_indicator, required_document_type,
        record_source
    from source_data

),

hashed as (

    select
        document_hkey,
        required_document_type_ck,
        received_indicator, required_document_type,
        {{ dbt_utils.generate_surrogate_key(['received_indicator', 'required_document_type']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by document_hkey, required_document_type_ck, hashdiff
        order by record_source
    ) = 1

)

select
    document_hkey,
    required_document_type_ck,
        received_indicator, required_document_type,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.document_hkey = d.document_hkey and t.required_document_type_ck = d.required_document_type_ck
      and t.hashdiff = d.hashdiff
)
{% endif %}
