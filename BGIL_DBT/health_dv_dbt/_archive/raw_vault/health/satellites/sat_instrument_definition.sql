{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_INSTRUMENT_DEFINITION
-- Parent: HUB_PAYMENT_INSTRUMENT
-- Multi-active grain key: none (single-active)
-- Single contributing source table: no intermediate view created (collapsed). No joins in THIS load.

with source_data as (

    select parent_bk, account_holder_name, branch_name, card_number_masked, instrument_type, record_source
    from (
        select distinct
            cheque_no as parent_bk,
            cast(null as varchar) as account_holder_name,
            cast(null as varchar) as branch_name,
            nullif(trim(to_varchar(debit_card_no)), '') as card_number_masked,
            cast(null as varchar) as instrument_type,
            'BJAZ_HM_HCM_EXTRACT' as record_source
        from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
        where cheque_no is not null
    )

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_PAYMENT_INSTRUMENT'", 'parent_bk']) }} as payment_instrument_hkey,
        parent_bk,
        account_holder_name, branch_name, card_number_masked, instrument_type,
        record_source
    from source_data

),

hashed as (

    select
        payment_instrument_hkey,
        account_holder_name, branch_name, card_number_masked, instrument_type,
        {{ dbt_utils.generate_surrogate_key(['account_holder_name', 'branch_name', 'card_number_masked', 'instrument_type']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by payment_instrument_hkey, hashdiff
        order by record_source
    ) = 1

)

select
    payment_instrument_hkey,
    account_holder_name, branch_name, card_number_masked, instrument_type,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.payment_instrument_hkey = d.payment_instrument_hkey
      and t.hashdiff = d.hashdiff
)
{% endif %}
