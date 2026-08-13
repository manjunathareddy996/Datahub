{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_QUOTE_HEADER
-- Parent: HUB_QUOTE
-- Multi-active grain key: none (single-active)
-- Source: {{ ref('int_health__sat_quote_header') }}. No joins in THIS load.

with source_data as (

    select parent_bk, quote_date, quote_remarks, quote_status, requested_cover_start_date, record_source
    from {{ ref('int_health__sat_quote_header') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_QUOTE'", 'parent_bk']) }} as quote_hkey,
        parent_bk,
        quote_date, quote_remarks, quote_status, requested_cover_start_date,
        record_source
    from source_data

),

hashed as (

    select
        quote_hkey,
        quote_date, quote_remarks, quote_status, requested_cover_start_date,
        {{ dbt_utils.generate_surrogate_key(['quote_date', 'quote_remarks', 'quote_status', 'requested_cover_start_date']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by quote_hkey, hashdiff
        order by record_source
    ) = 1

)

select
    quote_hkey,
    quote_date, quote_remarks, quote_status, requested_cover_start_date,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.quote_hkey = d.quote_hkey
      and t.hashdiff = d.hashdiff
)
{% endif %}
