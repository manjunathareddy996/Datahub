-- Intermediate harmonisation view for SAT_QUOTE_HEADER (HUB_QUOTE grain).
-- Stitched via a FULL OUTER JOIN + COALESCE chain across 3 table(s).
-- record_source lists every table that actually contributed to a given row.
select parent_bk, quote_date, quote_remarks, quote_status, requested_cover_start_date, record_source
from (
    with t0 as (
        select distinct
            quote_ref as parent_bk,
            nullif(trim(to_varchar(quote_status)), '') as quote_status
        from {{ ref('stg_health__bjaz_ecard_pol_dtls_config') }}
        where quote_ref is not null
        qualify row_number() over (partition by parent_bk order by quote_status) = 1
    ),
         t1 as (
        select distinct
            quote_sub_no as parent_bk,
            nullif(trim(to_varchar(register_date)), '') as quote_date,
            nullif(trim(to_varchar(remarks)), '') as quote_remarks,
            nullif(trim(to_varchar(quote_status)), '') as quote_status,
            nullif(trim(to_varchar(start_date)), '') as requested_cover_start_date
        from {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
        where quote_sub_no is not null
        qualify row_number() over (partition by parent_bk order by quote_date, quote_remarks, quote_status, requested_cover_start_date) = 1
    ),
         t2 as (
        select distinct
            quote_ref_no as parent_bk,
            nullif(trim(to_varchar(quote_status)), '') as quote_status
        from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
        where quote_ref_no is not null
        qualify row_number() over (partition by parent_bk order by quote_status) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk) as parent_bk,
        coalesce(t1.quote_date) as quote_date,
        coalesce(t1.quote_remarks) as quote_remarks,
        coalesce(t0.quote_status, t1.quote_status, t2.quote_status) as quote_status,
        coalesce(t1.requested_cover_start_date) as requested_cover_start_date,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BJAZ_ECARD_POL_DTLS_CONFIG' end, case when t1.parent_bk is not null then 'BJAZ_GRP_HLT_DTLS' end, case when t2.parent_bk is not null then 'BJAZ_HG_POL_DTLS' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk
    )
