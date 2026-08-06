-- Intermediate harmonisation view for SAT_DOCUMENT_DEFINITION (HUB_DOCUMENT grain).
-- Stitched via a FULL OUTER JOIN + COALESCE chain across 3 table(s).
-- record_source lists every table that actually contributed to a given row.
select parent_bk, document_category, document_name, document_reference_number, document_status, document_type, expiry_date, received_date, storage_reference, record_source
from (
    with t0 as (
        select distinct
            card_no as parent_bk,
            nullif(trim(to_varchar(card_status)), '') as document_status,
            nullif(trim(to_varchar(card_type)), '') as document_type,
            nullif(trim(to_varchar(card_expiry)), '') as expiry_date
        from {{ ref('stg_health__bjaz_card_dtls') }}
        where card_no is not null
        qualify row_number() over (partition by parent_bk order by document_status, document_type, expiry_date) = 1
    ),
         t1 as (
        select distinct
            inward_id as parent_bk,
            nullif(trim(to_varchar(pertain_to)), '') as document_category,
            nullif(trim(to_varchar(inward_no)), '') as document_reference_number,
            nullif(trim(to_varchar(doc_rec_date)), '') as received_date
        from {{ ref('stg_health__bjaz_hm_inward_dtls') }}
        where inward_id is not null
        qualify row_number() over (partition by parent_bk order by document_category, document_reference_number, received_date) = 1
    ),
         t2 as (
        select distinct
            omni_inward_no as parent_bk,
            nullif(trim(to_varchar(approval_file_name)), '') as document_name
        from {{ ref('stg_health__bjaz_remedinet_claim_details') }}
        where omni_inward_no is not null
        qualify row_number() over (partition by parent_bk order by document_name) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk) as parent_bk,
        coalesce(t1.document_category) as document_category,
        coalesce(t2.document_name) as document_name,
        coalesce(t1.document_reference_number) as document_reference_number,
        coalesce(t0.document_status) as document_status,
        coalesce(t0.document_type) as document_type,
        coalesce(t0.expiry_date) as expiry_date,
        coalesce(t1.received_date) as received_date,
        cast(null as varchar) as storage_reference,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BJAZ_CARD_DTLS' end, case when t1.parent_bk is not null then 'BJAZ_HM_INWARD_DTLS' end, case when t2.parent_bk is not null then 'BJAZ_REMEDINET_CLAIM_DETAILS' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk
    )
