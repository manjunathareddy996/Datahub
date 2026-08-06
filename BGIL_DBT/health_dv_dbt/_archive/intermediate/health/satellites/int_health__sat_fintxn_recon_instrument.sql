-- Intermediate harmonisation view for SAT_FINTXN_RECON_INSTRUMENT (HUB_FINANCIAL_TRANSACTION grain).
-- Stitched via a single source table, plus a UNION-appended fallback for 1 table(s) that lack the full multi-active child key.
-- record_source lists every table that actually contributed to a given row.
select parent_bk, instrument_sequence_ck, instrument_amount, instrument_date, instrument_reference, record_source
from (
    select distinct
        ptransaction_id as parent_bk,
        cast(null as varchar) as instrument_sequence_ck,
        nullif(trim(to_varchar(instrument_amt)), '') as instrument_amount,
        nullif(trim(to_varchar(instr_date)), '') as instrument_date,
        nullif(trim(to_varchar(instr_number)), '') as instrument_reference,
        'BJAZ_HEALTH_WEBSERVICE_INFO' as record_source
    from {{ ref('stg_health__bjaz_health_webservice_info') }}
    where ptransaction_id is not null
    )
