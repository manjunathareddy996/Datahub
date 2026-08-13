-- SHARED intermediate view for SAT_FINTXN_COMMISSION, SAT_FINTXN_HEADER, SAT_FINTXN_PREMIUM, SAT_FIN_RECEIPT -- identical (parent hub, grain, contributing tables); built once.
-- Stitched via a single source table.
-- record_source lists every table that actually contributed to a given row.
select parent_bk, commission_rate, gross_amount, narration, originating_system_reference, source_reference_number, transaction_date, base_premium, collection_mode, discount_amount, gross_premium, instalment_amount, instalment_number, loading_amount, net_premium, amount_received, authorisation_code, bank_reference, cheque_type, convenience_fee, merchant_reference, payment_gateway_reference, realisation_status, receipt_date, receipt_number, record_source
from (
        select distinct
            ptransaction_id as parent_bk,
            nullif(trim(to_varchar(comm_disc_rate)), '') as commission_rate,
            cast(null as varchar) as gross_amount,
            cast(null as varchar) as narration,
            cast(null as varchar) as originating_system_reference,
            cast(null as varchar) as source_reference_number,
            cast(null as varchar) as transaction_date,
            cast(null as varchar) as base_premium,
            cast(null as varchar) as collection_mode,
            cast(null as varchar) as discount_amount,
            cast(null as varchar) as gross_premium,
            cast(null as varchar) as instalment_amount,
            cast(null as varchar) as instalment_number,
            cast(null as varchar) as loading_amount,
            cast(null as varchar) as net_premium,
            cast(null as varchar) as amount_received,
            cast(null as varchar) as authorisation_code,
            cast(null as varchar) as bank_reference,
            cast(null as varchar) as cheque_type,
            cast(null as varchar) as convenience_fee,
            cast(null as varchar) as merchant_reference,
            cast(null as varchar) as payment_gateway_reference,
            cast(null as varchar) as realisation_status,
            cast(null as varchar) as receipt_date,
            cast(null as varchar) as receipt_number,
            'BJAZ_HEALTH_WEBSERVICE_INFO' as record_source
        from {{ ref('stg_health__bjaz_health_webservice_info') }}
        where ptransaction_id is not null
    )
