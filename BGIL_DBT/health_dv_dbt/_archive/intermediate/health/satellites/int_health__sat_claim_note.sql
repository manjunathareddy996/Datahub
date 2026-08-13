-- Intermediate harmonisation view for SAT_CLAIM_NOTE (HUB_CLAIM grain).
-- Stitched via a single source table, plus a UNION-appended fallback for 3 table(s) that lack the full multi-active child key.
-- record_source lists every table that actually contributed to a given row.
select * from (

select parent_bk, note_sequence_ck, follow_up_required_indicator, note_text, record_source from (
    select distinct
        claim_id as parent_bk,
        cast(null as varchar) as note_sequence_ck,
        cast(null as varchar) as follow_up_required_indicator,
        nullif(trim(to_varchar(genral_remarks)), '') as note_text,
        'BJAZ_HM_BILL_DETAIL' as record_source
    from {{ ref('stg_health__bjaz_hm_bill_detail') }}
    where claim_id is not null
    )

union all

select parent_bk, note_sequence_ck, follow_up_required_indicator, note_text, record_source from (
    select distinct
        claim_id as parent_bk,
        cast(null as varchar) as note_sequence_ck,
        nullif(trim(to_varchar(orphan_follow_flag)), '') as follow_up_required_indicator,
        nullif(trim(to_varchar(orphan_close_remark)), '') as note_text,
        'BJAZ_HM_ORPHAN_REG' as record_source
    from {{ ref('stg_health__bjaz_hm_orphan_reg') }}
    where claim_id is not null
    )

union all

select parent_bk, note_sequence_ck, follow_up_required_indicator, note_text, record_source from (
    select distinct
        claim_id as parent_bk,
        cast(null as varchar) as note_sequence_ck,
        cast(null as varchar) as follow_up_required_indicator,
        nullif(trim(to_varchar(query_remark)), '') as note_text,
        'BJAZ_HM_QUERY_REMARK' as record_source
    from {{ ref('stg_health__bjaz_hm_query_remark') }}
    where claim_id is not null
    )

)
