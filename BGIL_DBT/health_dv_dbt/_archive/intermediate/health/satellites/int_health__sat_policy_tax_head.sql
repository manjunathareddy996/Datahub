-- Intermediate harmonisation view for SAT_POLICY_TAX_HEAD (HUB_POLICY grain).
-- Stitched via a single source table, plus a UNION-appended fallback for 2 table(s) that lack the full multi-active child key.
-- record_source lists every table that actually contributed to a given row.
select * from (

select parent_bk, tax_head_code_ck, tax_amount, record_source from (
    select distinct
        pmasterpolicynumber as parent_bk,
        cast(null as varchar) as tax_head_code_ck,
        nullif(trim(to_varchar(pservicetax)), '') as tax_amount,
        'BJAZ_GENERIC_LOADER_LOG_TABLE' as record_source
    from {{ ref('stg_health__bjaz_generic_loader_log_table') }}
    where pmasterpolicynumber is not null
    )

union all

select parent_bk, tax_head_code_ck, tax_amount, record_source from (
    select distinct
        reg_no as parent_bk,
        cast(null as varchar) as tax_head_code_ck,
        nullif(trim(to_varchar(sertax_amt)), '') as tax_amount,
        'BJAZ_GRP_HLT_MATERNITY_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_maternity_dtls') }}
    where reg_no is not null
    )

)
