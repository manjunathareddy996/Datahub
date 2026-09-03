{{ config(materialized='view') }}

-- Feed for HUB_PAYMENT_INSTRUMENT: renames Maximus's PAYMENT_INSTRUMENT_BK / PAYMENT_INSTRUMENT_HKEY to the names
-- partner_dv_dbt already writes (PARENT_BK / PAYMENT_INSTRUMENT_HKEY), so both projects populate ONE
-- set of columns in the shared table instead of two.

    select PAYMENT_INSTRUMENT_HKEY as PAYMENT_INSTRUMENT_HKEY, PAYMENT_INSTRUMENT_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp__pd_prop_msdp_pv') }}
