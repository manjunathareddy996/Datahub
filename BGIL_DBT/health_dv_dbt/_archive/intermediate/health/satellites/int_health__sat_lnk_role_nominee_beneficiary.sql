-- Intermediate harmonisation view for SAT_LNK_ROLE_NOMINEE_BENEFICIARY (HUB_PARTY grain).
-- Stitched via a FULL OUTER JOIN + COALESCE chain across 13 table(s).
-- record_source lists every table that actually contributed to a given row.
select parent_bk, role_type_ck, relationship_to_insured, record_source
from (
    select parent_bk, 'NOMINEE_BENEFICIARY' as role_type_ck, relationship_to_insured, record_source
    from (
    with t0 as (
        select distinct
            pd_premium_payer_id as parent_bk,
            nullif(trim(to_varchar(md_nominee_relation)), '') as relationship_to_insured
        from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
        where pd_premium_payer_id is not null
        qualify row_number() over (partition by parent_bk order by relationship_to_insured) = 1
    ),
         t1 as (
        select distinct
            pd_premium_payer_id as parent_bk,
            nullif(trim(to_varchar(md_nominee_relation)), '') as relationship_to_insured
        from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
        where pd_premium_payer_id is not null
        qualify row_number() over (partition by parent_bk order by relationship_to_insured) = 1
    ),
         t2 as (
        select distinct
            pd_premium_payer_id as parent_bk,
            nullif(trim(to_varchar(md_nominee_relation)), '') as relationship_to_insured
        from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
        where pd_premium_payer_id is not null
        qualify row_number() over (partition by parent_bk order by relationship_to_insured) = 1
    ),
         t3 as (
        select distinct
            pd_premium_payer_id as parent_bk,
            nullif(trim(to_varchar(md_nominee_relation)), '') as relationship_to_insured
        from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
        where pd_premium_payer_id is not null
        qualify row_number() over (partition by parent_bk order by relationship_to_insured) = 1
    ),
         t4 as (
        select distinct
            customer_id as parent_bk,
            nullif(trim(to_varchar(nominee_relation)), '') as relationship_to_insured
        from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
        where customer_id is not null
        qualify row_number() over (partition by parent_bk order by relationship_to_insured) = 1
    ),
         t5 as (
        select distinct
            member_no as parent_bk,
            nullif(trim(to_varchar(nominee_rltn)), '') as relationship_to_insured
        from {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
        where member_no is not null
        qualify row_number() over (partition by parent_bk order by relationship_to_insured) = 1
    ),
         t6 as (
        select distinct
            user_id as parent_bk,
            nullif(trim(to_varchar(nominee_relation)), '') as relationship_to_insured
        from {{ ref('stg_health__bjaz_gp_hospital_cash') }}
        where user_id is not null
        qualify row_number() over (partition by parent_bk order by relationship_to_insured) = 1
    ),
         t7 as (
        select distinct
            member_no as parent_bk,
            nullif(trim(to_varchar(assignee_relation)), '') as relationship_to_insured
        from {{ ref('stg_health__bjaz_hcf_member_dtls') }}
        where member_no is not null
        qualify row_number() over (partition by parent_bk order by relationship_to_insured) = 1
    ),
         t8 as (
        select distinct
            part_id as parent_bk,
            nullif(trim(to_varchar(nominee_rltn)), '') as relationship_to_insured
        from {{ ref('stg_health__bjaz_hc_part_extn') }}
        where part_id is not null
        qualify row_number() over (partition by parent_bk order by relationship_to_insured) = 1
    ),
         t9 as (
        select distinct
            client_id as parent_bk,
            nullif(trim(to_varchar(nominee_relation)), '') as relationship_to_insured
        from {{ ref('stg_health__bjaz_hdfc_sec_fhpp') }}
        where client_id is not null
        qualify row_number() over (partition by parent_bk order by relationship_to_insured) = 1
    ),
         t10 as (
        select distinct
            member_no as parent_bk,
            nullif(trim(to_varchar(nominee_rltn)), '') as relationship_to_insured
        from {{ ref('stg_health__bjaz_hlt_ensure_mem_dtls') }}
        where member_no is not null
        qualify row_number() over (partition by parent_bk order by relationship_to_insured) = 1
    ),
         t11 as (
        select distinct
            member_no as parent_bk,
            nullif(trim(to_varchar(nominee_rltn)), '') as relationship_to_insured
        from {{ ref('stg_health__bjaz_ihg_mem_dtls_extn') }}
        where member_no is not null
        qualify row_number() over (partition by parent_bk order by relationship_to_insured) = 1
    ),
         t12 as (
        select distinct
            member_no as parent_bk,
            nullif(trim(to_varchar(nominee_rltn)), '') as relationship_to_insured
        from {{ ref('stg_health__bjaz_sh_mem_dtls_extn') }}
        where member_no is not null
        qualify row_number() over (partition by parent_bk order by relationship_to_insured) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk, t4.parent_bk, t5.parent_bk, t6.parent_bk, t7.parent_bk, t8.parent_bk, t9.parent_bk, t10.parent_bk, t11.parent_bk, t12.parent_bk) as parent_bk,
        coalesce(t0.relationship_to_insured, t1.relationship_to_insured, t2.relationship_to_insured, t3.relationship_to_insured, t4.relationship_to_insured, t5.relationship_to_insured, t6.relationship_to_insured, t7.relationship_to_insured, t8.relationship_to_insured, t9.relationship_to_insured, t10.relationship_to_insured, t11.relationship_to_insured, t12.relationship_to_insured) as relationship_to_insured,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BA_HCP_PROD_8428_GPG_LOADER' end, case when t1.parent_bk is not null then 'BA_HCP_PROD_8432_ECP_LOADER' end, case when t2.parent_bk is not null then 'BA_HCP_PROD_8433_FHC_LOADER' end, case when t3.parent_bk is not null then 'BA_HCP_PROD_8439_CLH_LOADER' end, case when t4.parent_bk is not null then 'BJAZ_BANDHAN_MEDI_CLAM' end, case when t5.parent_bk is not null then 'BJAZ_EC_MEM_DTLS_EXTN' end, case when t6.parent_bk is not null then 'BJAZ_GP_HOSPITAL_CASH' end, case when t7.parent_bk is not null then 'BJAZ_HCF_MEMBER_DTLS' end, case when t8.parent_bk is not null then 'BJAZ_HC_PART_EXTN' end, case when t9.parent_bk is not null then 'BJAZ_HDFC_SEC_FHPP' end, case when t10.parent_bk is not null then 'BJAZ_HLT_ENSURE_MEM_DTLS' end, case when t11.parent_bk is not null then 'BJAZ_IHG_MEM_DTLS_EXTN' end, case when t12.parent_bk is not null then 'BJAZ_SH_MEM_DTLS_EXTN' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk
    full outer join t3 on coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk) = t3.parent_bk
    full outer join t4 on coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk) = t4.parent_bk
    full outer join t5 on coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk) = t5.parent_bk
    full outer join t6 on coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk) = t6.parent_bk
    full outer join t7 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk) = t7.parent_bk
    full outer join t8 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk) = t8.parent_bk
    full outer join t9 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk) = t9.parent_bk
    full outer join t10 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk) = t10.parent_bk
    full outer join t11 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk) = t11.parent_bk
    full outer join t12 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk) = t12.parent_bk
    )
)
