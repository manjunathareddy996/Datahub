-- Intermediate harmonisation view for SAT_DOCUMENT_CHECKLIST (HUB_DOCUMENT grain).
-- Stitched via a single source table, plus a UNION-appended fallback for 1 table(s) that lack the full multi-active child key.
-- record_source lists every table that actually contributed to a given row.
select parent_bk, required_document_type_ck, received_indicator, required_document_type, record_source
from (
    select distinct
        omni_inward_no as parent_bk,
        cast(null as varchar) as required_document_type_ck,
        nullif(trim(to_varchar(is_document_received)), '') as received_indicator,
        cast(null as varchar) as required_document_type,
        'BJAZ_REMEDINET_CLAIM_DETAILS' as record_source
    from {{ ref('stg_health__bjaz_remedinet_claim_details') }}
    where omni_inward_no is not null
    )
