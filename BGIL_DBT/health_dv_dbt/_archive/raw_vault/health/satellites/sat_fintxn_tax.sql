{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_FINTXN_TAX
-- Parent: HUB_FINANCIAL_TRANSACTION
-- Multi-active grain key: Tax Type
-- Source: {{ ref('int_health__sat_fintxn_tax') }}. No joins in THIS load.

with source_data as (

    select parent_bk, tax_type_ck, cess_amount, cgst_amount, component_tax_amount, igst_amount, service_tax_amount, service_tax_exemption_indicator, service_tax_rate, service_tax_registration_number, sgst_amount, tax_type, tds_rate, record_source
    from {{ ref('int_health__sat_fintxn_tax') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_FINANCIAL_TRANSACTION'", 'parent_bk']) }} as financial_transaction_hkey,
        parent_bk, tax_type_ck,
        cess_amount, cgst_amount, component_tax_amount, igst_amount, service_tax_amount, service_tax_exemption_indicator, service_tax_rate, service_tax_registration_number, sgst_amount, tax_type, tds_rate,
        record_source
    from source_data

),

hashed as (

    select
        financial_transaction_hkey,
        tax_type_ck,
        cess_amount, cgst_amount, component_tax_amount, igst_amount, service_tax_amount, service_tax_exemption_indicator, service_tax_rate, service_tax_registration_number, sgst_amount, tax_type, tds_rate,
        {{ dbt_utils.generate_surrogate_key(['cess_amount', 'cgst_amount', 'component_tax_amount', 'igst_amount', 'service_tax_amount', 'service_tax_exemption_indicator', 'service_tax_rate', 'service_tax_registration_number', 'sgst_amount', 'tax_type', 'tds_rate']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by financial_transaction_hkey, tax_type_ck, hashdiff
        order by record_source
    ) = 1

)

select
    financial_transaction_hkey,
    tax_type_ck,
        cess_amount, cgst_amount, component_tax_amount, igst_amount, service_tax_amount, service_tax_exemption_indicator, service_tax_rate, service_tax_registration_number, sgst_amount, tax_type, tds_rate,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.financial_transaction_hkey = d.financial_transaction_hkey and t.tax_type_ck = d.tax_type_ck
      and t.hashdiff = d.hashdiff
)
{% endif %}
