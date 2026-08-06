{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_AGREEMENT_COMMERCIAL_TERMS
-- Parent: HUB_AGREEMENT
-- Multi-active grain key: none (single-active)
-- Source: {{ ref('int_health__sat_shared__agreement_commercial_terms_agreement_sla') }} (SHARED with sibling satellite(s)). No joins in THIS load.

with source_data as (

    select parent_bk, credit_period, payment_terms, record_source
    from {{ ref('int_health__sat_shared__agreement_commercial_terms_agreement_sla') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_AGREEMENT'", 'parent_bk']) }} as agreement_hkey,
        parent_bk,
        credit_period, payment_terms,
        record_source
    from source_data

),

hashed as (

    select
        agreement_hkey,
        credit_period, payment_terms,
        {{ dbt_utils.generate_surrogate_key(['credit_period', 'payment_terms']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by agreement_hkey, hashdiff
        order by record_source
    ) = 1

)

select
    agreement_hkey,
    credit_period, payment_terms,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.agreement_hkey = d.agreement_hkey
      and t.hashdiff = d.hashdiff
)
{% endif %}
