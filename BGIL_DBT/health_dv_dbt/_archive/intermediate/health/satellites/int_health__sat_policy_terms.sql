-- Intermediate harmonisation view for SAT_POLICY_TERMS (HUB_POLICY grain).
-- Stitched via a FULL OUTER JOIN + COALESCE chain across 9 table(s).
-- record_source lists every table that actually contributed to a given row.
select parent_bk, co_payment_percentage, deductible_total, special_conditions, record_source
from (
    with t0 as (
        select distinct
            pol_serial_no as parent_bk,
            nullif(trim(to_varchar(plc_special_terms_conditions)), '') as special_conditions
        from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
        where pol_serial_no is not null
        qualify row_number() over (partition by parent_bk order by special_conditions) = 1
    ),
         t1 as (
        select distinct
            pol_serial_no as parent_bk,
            nullif(trim(to_varchar(plc_aggr_deductible)), '') as deductible_total,
            nullif(trim(to_varchar(plc_special_terms_conditions)), '') as special_conditions
        from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
        where pol_serial_no is not null
        qualify row_number() over (partition by parent_bk order by deductible_total, special_conditions) = 1
    ),
         t2 as (
        select distinct
            pol_serial_no as parent_bk,
            nullif(trim(to_varchar(plc_special_terms_conditions)), '') as special_conditions
        from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
        where pol_serial_no is not null
        qualify row_number() over (partition by parent_bk order by special_conditions) = 1
    ),
         t3 as (
        select distinct
            pol_serial_no as parent_bk,
            nullif(trim(to_varchar(plc_special_terms_conditions)), '') as special_conditions
        from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
        where pol_serial_no is not null
        qualify row_number() over (partition by parent_bk order by special_conditions) = 1
    ),
         t4 as (
        select distinct
            reference_id as parent_bk,
            nullif(trim(to_varchar(spcl_terms_cond)), '') as special_conditions
        from {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
        where reference_id is not null
        qualify row_number() over (partition by parent_bk order by special_conditions) = 1
    ),
         t5 as (
        select distinct
            reg_no as parent_bk,
            nullif(trim(to_varchar(other_conditions)), '') as special_conditions
        from {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
        where reg_no is not null
        qualify row_number() over (partition by parent_bk order by special_conditions) = 1
    ),
         t6 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(voluntary_co_pay)), '') as co_payment_percentage,
            nullif(trim(to_varchar(aggregate_deductible)), '') as deductible_total
        from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by co_payment_percentage, deductible_total) = 1
    ),
         t7 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(special_condition)), '') as special_conditions
        from {{ ref('stg_health__bjaz_hlt_ensure_mem_dtls') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by special_conditions) = 1
    ),
         t8 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(special_condition)), '') as special_conditions
        from {{ ref('stg_health__bjaz_illness_bases_extn') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by special_conditions) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk, t4.parent_bk, t5.parent_bk, t6.parent_bk, t7.parent_bk, t8.parent_bk) as parent_bk,
        coalesce(t6.co_payment_percentage) as co_payment_percentage,
        coalesce(t1.deductible_total, t6.deductible_total) as deductible_total,
        coalesce(t0.special_conditions, t1.special_conditions, t2.special_conditions, t3.special_conditions, t4.special_conditions, t5.special_conditions, t7.special_conditions, t8.special_conditions) as special_conditions,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BA_HCP_PROD_8428_GPG_LOADER' end, case when t1.parent_bk is not null then 'BA_HCP_PROD_8432_ECP_LOADER' end, case when t2.parent_bk is not null then 'BA_HCP_PROD_8433_FHC_LOADER' end, case when t3.parent_bk is not null then 'BA_HCP_PROD_8439_CLH_LOADER' end, case when t4.parent_bk is not null then 'BJAZ_GPG_POL_DTLS' end, case when t5.parent_bk is not null then 'BJAZ_GRP_HLT_DTLS' end, case when t6.parent_bk is not null then 'BJAZ_HG_POL_DTLS' end, case when t7.parent_bk is not null then 'BJAZ_HLT_ENSURE_MEM_DTLS' end, case when t8.parent_bk is not null then 'BJAZ_ILLNESS_BASES_EXTN' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk
    full outer join t3 on coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk) = t3.parent_bk
    full outer join t4 on coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk) = t4.parent_bk
    full outer join t5 on coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk) = t5.parent_bk
    full outer join t6 on coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk) = t6.parent_bk
    full outer join t7 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk) = t7.parent_bk
    full outer join t8 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk) = t8.parent_bk
    )
