-- SHARED intermediate view for SAT_CLAIM_DISBURSEMENT_BATCH, SAT_CLAIM_FNOL -- identical (parent hub, grain, contributing tables); built once.
-- Stitched via a single source table.
-- record_source lists every table that actually contributed to a given row.
select parent_bk, batch_date, batch_reference, preliminary_loss_estimate, record_source
from (
        select distinct
            bjaz_claim_id as parent_bk,
            nullif(trim(to_varchar(float_date)), '') as batch_date,
            nullif(trim(to_varchar(float_no)), '') as batch_reference,
            cast(null as varchar) as preliminary_loss_estimate,
            'BJAZ_TPA_CLAIM_DETAILS_WS' as record_source
        from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
        where bjaz_claim_id is not null
    )
