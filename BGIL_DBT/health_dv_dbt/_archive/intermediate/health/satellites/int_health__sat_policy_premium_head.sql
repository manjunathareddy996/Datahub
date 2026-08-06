-- Intermediate harmonisation view for SAT_POLICY_PREMIUM_HEAD (HUB_POLICY grain).
-- Stitched via a single source table, plus a UNION-appended fallback for 5 table(s) that lack the full multi-active child key.
-- record_source lists every table that actually contributed to a given row.
select * from (

select parent_bk, premium_head_code_ck, base_amount, net_head_premium, premium_basis, record_source from (
    select distinct
        contract_id as parent_bk,
        cast(null as varchar) as premium_head_code_ck,
        nullif(trim(to_varchar(prem_base_cover)), '') as base_amount,
        cast(null as varchar) as net_head_premium,
        cast(null as varchar) as premium_basis,
        'BA_HCP_DT_MEM' as record_source
    from {{ ref('stg_health__ba_hcp_dt_mem') }}
    where contract_id is not null
    )

union all

select parent_bk, premium_head_code_ck, base_amount, net_head_premium, premium_basis, record_source from (
    select distinct
        reg_no as parent_bk,
        cast(null as varchar) as premium_head_code_ck,
        cast(null as varchar) as base_amount,
        cast(null as varchar) as net_head_premium,
        nullif(trim(to_varchar(per_person_prem_type)), '') as premium_basis,
        'BJAZ_GRP_HLT_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
    where reg_no is not null
    )

union all

select parent_bk, premium_head_code_ck, base_amount, net_head_premium, premium_basis, record_source from (
    select distinct
        reg_no as parent_bk,
        cast(null as varchar) as premium_head_code_ck,
        nullif(trim(to_varchar(prime_rider_base_prem)), '') as base_amount,
        nullif(trim(to_varchar(permium_co_buffer)), '') as net_head_premium,
        cast(null as varchar) as premium_basis,
        'BJAZ_GRP_HLT_MATERNITY_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_maternity_dtls') }}
    where reg_no is not null
    )

union all

select parent_bk, premium_head_code_ck, base_amount, net_head_premium, premium_basis, record_source from (
    select distinct
        contract_id as parent_bk,
        cast(null as varchar) as premium_head_code_ck,
        cast(null as varchar) as base_amount,
        nullif(trim(to_varchar(adon_premium)), '') as net_head_premium,
        cast(null as varchar) as premium_basis,
        'BJAZ_HCF_MEMBER_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hcf_member_dtls') }}
    where contract_id is not null
    )

union all

select parent_bk, premium_head_code_ck, base_amount, net_head_premium, premium_basis, record_source from (
    select distinct
        policy_ref as parent_bk,
        cast(null as varchar) as premium_head_code_ck,
        nullif(trim(to_varchar(surg_cover_base_prem)), '') as base_amount,
        cast(null as varchar) as net_head_premium,
        cast(null as varchar) as premium_basis,
        'BJAZ_HEALTH_WEBSERVICE_INFO' as record_source
    from {{ ref('stg_health__bjaz_health_webservice_info') }}
    where policy_ref is not null
    )

)
