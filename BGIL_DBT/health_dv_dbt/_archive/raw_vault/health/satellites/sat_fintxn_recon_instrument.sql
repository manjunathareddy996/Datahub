{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_FINTXN_RECON_INSTRUMENT
-- Parent: HUB_FINANCIAL_TRANSACTION
-- Multi-active grain key: Instrument Sequence
-- Source: {{ ref('int_health__sat_fintxn_recon_instrument') }}. No joins in THIS load.

with source_data as (

    select parent_bk, instrument_sequence_ck, instrument_amount, instrument_date, instrument_reference, record_source
    from {{ ref('int_health__sat_fintxn_recon_instrument') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_FINANCIAL_TRANSACTION'", 'parent_bk']) }} as financial_transaction_hkey,
        parent_bk, instrument_sequence_ck,
        instrument_amount, instrument_date, instrument_reference,
        record_source
    from source_data

),

hashed as (

    select
        financial_transaction_hkey,
        instrument_sequence_ck,
        instrument_amount, instrument_date, instrument_reference,
        {{ dbt_utils.generate_surrogate_key(['instrument_amount', 'instrument_date', 'instrument_reference']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by financial_transaction_hkey, instrument_sequence_ck, hashdiff
        order by record_source
    ) = 1

)

select
    financial_transaction_hkey,
    instrument_sequence_ck,
        instrument_amount, instrument_date, instrument_reference,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.financial_transaction_hkey = d.financial_transaction_hkey and t.instrument_sequence_ck = d.instrument_sequence_ck
      and t.hashdiff = d.hashdiff
)
{% endif %}
