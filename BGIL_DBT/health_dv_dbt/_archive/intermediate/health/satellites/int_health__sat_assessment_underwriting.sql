-- Intermediate harmonisation view for SAT_ASSESSMENT_UNDERWRITING (HUB_ASSESSMENT grain).
-- Stitched via a FULL OUTER JOIN + COALESCE chain across 3 table(s).
-- record_source lists every table that actually contributed to a given row.
select parent_bk, special_conditions_recommended, underwriting_remarks, record_source
from (
    with t0 as (
        select distinct
            pd_scrutiny_number as parent_bk,
            nullif(trim(to_varchar(md_spcl_condtn_member_level)), '') as special_conditions_recommended
        from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
        where pd_scrutiny_number is not null
        qualify row_number() over (partition by parent_bk order by special_conditions_recommended) = 1
    ),
         t1 as (
        select distinct
            pd_scrutiny_number as parent_bk,
            nullif(trim(to_varchar(md_spcl_condtn_member_level)), '') as special_conditions_recommended
        from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
        where pd_scrutiny_number is not null
        qualify row_number() over (partition by parent_bk order by special_conditions_recommended) = 1
    ),
         t2 as (
        select distinct
            scrutiny_no as parent_bk,
            nullif(trim(to_varchar(uw_remark)), '') as underwriting_remarks
        from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
        where scrutiny_no is not null
        qualify row_number() over (partition by parent_bk order by underwriting_remarks) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk) as parent_bk,
        coalesce(t0.special_conditions_recommended, t1.special_conditions_recommended) as special_conditions_recommended,
        coalesce(t2.underwriting_remarks) as underwriting_remarks,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BA_HCP_PROD_8432_ECP_LOADER' end, case when t1.parent_bk is not null then 'BA_HCP_PROD_8439_CLH_LOADER' end, case when t2.parent_bk is not null then 'BJAZ_BANDHAN_MEDI_CLAM' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk
    )
