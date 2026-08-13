-- Intermediate harmonisation view for SAT_PARTY_BANKING (HUB_PARTY grain).
-- Stitched via a FULL OUTER JOIN + COALESCE chain across 4 table(s), plus a UNION-appended fallback for 3 table(s) that lack the full multi-active child key.
-- record_source lists every table that actually contributed to a given row.
select * from (

select parent_bk, account_number_masked_ck, account_holder_name, account_number_masked, account_status, account_type, bank_name, ifsc_code, micr_code, record_source from (
    with t0 as (
        select distinct
            customer_id as parent_bk,
            nullif(trim(to_varchar(account_number)), '') as account_number_masked_ck,
            nullif(trim(to_varchar(account_number)), '') as account_number_masked
        from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
        where customer_id is not null and account_number is not null
        qualify row_number() over (partition by parent_bk, account_number_masked_ck order by account_number_masked) = 1
    ),
         t1 as (
        select distinct
            hospital_id as parent_bk,
            nullif(trim(to_varchar(account_no)), '') as account_number_masked_ck,
            nullif(trim(to_varchar(account_no)), '') as account_number_masked,
            nullif(trim(to_varchar(bank_name)), '') as bank_name
        from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
        where hospital_id is not null and account_no is not null
        qualify row_number() over (partition by parent_bk, account_number_masked_ck order by account_number_masked, bank_name) = 1
    ),
         t2 as (
        select distinct
            hosid as parent_bk,
            nullif(trim(to_varchar(account_no)), '') as account_number_masked_ck,
            nullif(trim(to_varchar(name_bank_account)), '') as account_holder_name,
            nullif(trim(to_varchar(account_no)), '') as account_number_masked,
            nullif(trim(to_varchar(account_type)), '') as account_type,
            nullif(trim(to_varchar(bank_name)), '') as bank_name,
            nullif(trim(to_varchar(ifsc_code_neft)), '') as ifsc_code,
            nullif(trim(to_varchar(br_micr_code)), '') as micr_code
        from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
        where hosid is not null and account_no is not null
        qualify row_number() over (partition by parent_bk, account_number_masked_ck order by account_holder_name, account_number_masked, account_type, bank_name, ifsc_code, micr_code) = 1
    ),
         t3 as (
        select distinct
            customer_id as parent_bk,
            nullif(trim(to_varchar(account_no)), '') as account_number_masked_ck,
            nullif(trim(to_varchar(account_no)), '') as account_number_masked,
            nullif(trim(to_varchar(neft_bank_status)), '') as account_status,
            nullif(trim(to_varchar(account_type)), '') as account_type,
            nullif(trim(to_varchar(bank_name)), '') as bank_name,
            nullif(trim(to_varchar(branch_ifsc_code)), '') as ifsc_code,
            nullif(trim(to_varchar(branch_micr_code)), '') as micr_code
        from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
        where customer_id is not null and account_no is not null
        qualify row_number() over (partition by parent_bk, account_number_masked_ck order by account_number_masked, account_status, account_type, bank_name, ifsc_code, micr_code) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk) as parent_bk,
        coalesce(t0.account_number_masked_ck, t1.account_number_masked_ck, t2.account_number_masked_ck, t3.account_number_masked_ck) as account_number_masked_ck,
        coalesce(t2.account_holder_name) as account_holder_name,
        coalesce(t0.account_number_masked, t1.account_number_masked, t2.account_number_masked, t3.account_number_masked) as account_number_masked,
        coalesce(t3.account_status) as account_status,
        coalesce(t2.account_type, t3.account_type) as account_type,
        coalesce(t1.bank_name, t2.bank_name, t3.bank_name) as bank_name,
        coalesce(t2.ifsc_code, t3.ifsc_code) as ifsc_code,
        coalesce(t2.micr_code, t3.micr_code) as micr_code,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BJAZ_BANDHAN_MEDI_CLAM' end, case when t1.parent_bk is not null then 'BJAZ_HM_HCM_EXTRACT' end, case when t2.parent_bk is not null then 'BJAZ_HM_HOSPITAL_MASTER_EXTN' end, case when t3.parent_bk is not null then 'BJAZ_TPA_CLAIM_DETAILS_WS' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk and t0.account_number_masked_ck = t1.account_number_masked_ck
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk and coalesce(t0.account_number_masked_ck, t1.account_number_masked_ck) = t2.account_number_masked_ck
    full outer join t3 on coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk) = t3.parent_bk and coalesce(coalesce(t0.account_number_masked_ck, t1.account_number_masked_ck), t2.account_number_masked_ck) = t3.account_number_masked_ck
    )

union all

select parent_bk, account_number_masked_ck, account_holder_name, account_number_masked, account_status, account_type, bank_name, ifsc_code, micr_code, record_source from (
    select distinct
        pd_premium_payer_id as parent_bk,
        cast(null as varchar) as account_number_masked_ck,
        cast(null as varchar) as account_holder_name,
        cast(null as varchar) as account_number_masked,
        cast(null as varchar) as account_status,
        cast(null as varchar) as account_type,
        nullif(trim(to_varchar(mlac_emi_pc_bank_name)), '') as bank_name,
        cast(null as varchar) as ifsc_code,
        cast(null as varchar) as micr_code,
        'BA_HCP_PROD_8428_GPG_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
    where pd_premium_payer_id is not null
    )

union all

select parent_bk, account_number_masked_ck, account_holder_name, account_number_masked, account_status, account_type, bank_name, ifsc_code, micr_code, record_source from (
    select distinct
        pd_premium_payer_id as parent_bk,
        cast(null as varchar) as account_number_masked_ck,
        cast(null as varchar) as account_holder_name,
        cast(null as varchar) as account_number_masked,
        cast(null as varchar) as account_status,
        cast(null as varchar) as account_type,
        nullif(trim(to_varchar(plc_bank_name)), '') as bank_name,
        cast(null as varchar) as ifsc_code,
        cast(null as varchar) as micr_code,
        'BA_HCP_PROD_8439_CLH_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
    where pd_premium_payer_id is not null
    )

union all

select parent_bk, account_number_masked_ck, account_holder_name, account_number_masked, account_status, account_type, bank_name, ifsc_code, micr_code, record_source from (
    select distinct
        member_id as parent_bk,
        cast(null as varchar) as account_number_masked_ck,
        cast(null as varchar) as account_holder_name,
        cast(null as varchar) as account_number_masked,
        cast(null as varchar) as account_status,
        cast(null as varchar) as account_type,
        nullif(trim(to_varchar(bank_name)), '') as bank_name,
        cast(null as varchar) as ifsc_code,
        nullif(trim(to_varchar(micr_code)), '') as micr_code,
        'BJAZ_HM_MEMBER_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_member_dtls') }}
    where member_id is not null
    )

)
