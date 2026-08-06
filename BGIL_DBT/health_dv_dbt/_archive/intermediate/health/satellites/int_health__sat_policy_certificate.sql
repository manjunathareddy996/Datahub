-- Intermediate harmonisation view for SAT_POLICY_CERTIFICATE (HUB_POLICY grain).
-- Stitched via a single source table, plus a UNION-appended fallback for 13 table(s) that lack the full multi-active child key.
-- record_source lists every table that actually contributed to a given row.
select * from (

select parent_bk, certificate_number_ck, certificate_number, coverage_end_date, coverage_start_date, enrolment_date, exit_reason, member_premium, member_status, relationship_to_primary, record_source from (
        select distinct
            policy_ref as parent_bk,
            nullif(trim(to_varchar(certificate_no)), '') as certificate_number_ck,
            nullif(trim(to_varchar(certificate_no)), '') as certificate_number,
            cast(null as varchar) as coverage_end_date,
            cast(null as varchar) as coverage_start_date,
            cast(null as varchar) as enrolment_date,
            cast(null as varchar) as exit_reason,
            cast(null as varchar) as member_premium,
            cast(null as varchar) as member_status,
            cast(null as varchar) as relationship_to_primary,
            'BJAZ_HM_INWARD_DTLS' as record_source
        from {{ ref('stg_health__bjaz_hm_inward_dtls') }}
        where policy_ref is not null and certificate_no is not null
    )

union all

select parent_bk, certificate_number_ck, certificate_number, coverage_end_date, coverage_start_date, enrolment_date, exit_reason, member_premium, member_status, relationship_to_primary, record_source from (
    select distinct
        contract_id as parent_bk,
        cast(null as varchar) as certificate_number_ck,
        cast(null as varchar) as certificate_number,
        cast(null as varchar) as coverage_end_date,
        cast(null as varchar) as coverage_start_date,
        cast(null as varchar) as enrolment_date,
        cast(null as varchar) as exit_reason,
        cast(null as varchar) as member_premium,
        nullif(trim(to_varchar(mem_status)), '') as member_status,
        cast(null as varchar) as relationship_to_primary,
        'BA_HCP_DT_MEM' as record_source
    from {{ ref('stg_health__ba_hcp_dt_mem') }}
    where contract_id is not null
    )

union all

select parent_bk, certificate_number_ck, certificate_number, coverage_end_date, coverage_start_date, enrolment_date, exit_reason, member_premium, member_status, relationship_to_primary, record_source from (
    select distinct
        contract_id as parent_bk,
        cast(null as varchar) as certificate_number_ck,
        cast(null as varchar) as certificate_number,
        cast(null as varchar) as coverage_end_date,
        cast(null as varchar) as coverage_start_date,
        cast(null as varchar) as enrolment_date,
        cast(null as varchar) as exit_reason,
        cast(null as varchar) as member_premium,
        nullif(trim(to_varchar(mem_status)), '') as member_status,
        cast(null as varchar) as relationship_to_primary,
        'BA_HCP_DT_MEM_COV' as record_source
    from {{ ref('stg_health__ba_hcp_dt_mem_cov') }}
    where contract_id is not null
    )

union all

select parent_bk, certificate_number_ck, certificate_number, coverage_end_date, coverage_start_date, enrolment_date, exit_reason, member_premium, member_status, relationship_to_primary, record_source from (
    select distinct
        contract_id as parent_bk,
        cast(null as varchar) as certificate_number_ck,
        cast(null as varchar) as certificate_number,
        cast(null as varchar) as coverage_end_date,
        cast(null as varchar) as coverage_start_date,
        cast(null as varchar) as enrolment_date,
        cast(null as varchar) as exit_reason,
        cast(null as varchar) as member_premium,
        nullif(trim(to_varchar(mem_status)), '') as member_status,
        cast(null as varchar) as relationship_to_primary,
        'BA_HCP_DT_POL_COV' as record_source
    from {{ ref('stg_health__ba_hcp_dt_pol_cov') }}
    where contract_id is not null
    )

union all

select parent_bk, certificate_number_ck, certificate_number, coverage_end_date, coverage_start_date, enrolment_date, exit_reason, member_premium, member_status, relationship_to_primary, record_source from (
    select distinct
        policy_no as parent_bk,
        cast(null as varchar) as certificate_number_ck,
        cast(null as varchar) as certificate_number,
        cast(null as varchar) as coverage_end_date,
        cast(null as varchar) as coverage_start_date,
        cast(null as varchar) as enrolment_date,
        cast(null as varchar) as exit_reason,
        nullif(trim(to_varchar(annual_premium)), '') as member_premium,
        cast(null as varchar) as member_status,
        nullif(trim(to_varchar(dwh_relationship)), '') as relationship_to_primary,
        'BGIL_GMC_FINAL_INSTL_DATA' as record_source
    from {{ ref('stg_health__bgil_gmc_final_instl_data') }}
    where policy_no is not null
    )

union all

select parent_bk, certificate_number_ck, certificate_number, coverage_end_date, coverage_start_date, enrolment_date, exit_reason, member_premium, member_status, relationship_to_primary, record_source from (
    select distinct
        contract_id as parent_bk,
        cast(null as varchar) as certificate_number_ck,
        cast(null as varchar) as certificate_number,
        cast(null as varchar) as coverage_end_date,
        cast(null as varchar) as coverage_start_date,
        nullif(trim(to_varchar(pm_pol_enrolment_date)), '') as enrolment_date,
        cast(null as varchar) as exit_reason,
        cast(null as varchar) as member_premium,
        cast(null as varchar) as member_status,
        cast(null as varchar) as relationship_to_primary,
        'BJAZ_CTNGY_PA_MEM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ctngy_pa_mem_dtls') }}
    where contract_id is not null
    )

union all

select parent_bk, certificate_number_ck, certificate_number, coverage_end_date, coverage_start_date, enrolment_date, exit_reason, member_premium, member_status, relationship_to_primary, record_source from (
    select distinct
        contract_id as parent_bk,
        cast(null as varchar) as certificate_number_ck,
        cast(null as varchar) as certificate_number,
        cast(null as varchar) as coverage_end_date,
        nullif(trim(to_varchar(effetive_date)), '') as coverage_start_date,
        cast(null as varchar) as enrolment_date,
        cast(null as varchar) as exit_reason,
        nullif(trim(to_varchar(premium)), '') as member_premium,
        nullif(trim(to_varchar(status)), '') as member_status,
        cast(null as varchar) as relationship_to_primary,
        'BJAZ_EC_MEM_DTLS_EXTN' as record_source
    from {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
    where contract_id is not null
    )

union all

select parent_bk, certificate_number_ck, certificate_number, coverage_end_date, coverage_start_date, enrolment_date, exit_reason, member_premium, member_status, relationship_to_primary, record_source from (
    select distinct
        contract_id as parent_bk,
        cast(null as varchar) as certificate_number_ck,
        cast(null as varchar) as certificate_number,
        cast(null as varchar) as coverage_end_date,
        cast(null as varchar) as coverage_start_date,
        nullif(trim(to_varchar(join_date)), '') as enrolment_date,
        cast(null as varchar) as exit_reason,
        nullif(trim(to_varchar(premium)), '') as member_premium,
        nullif(trim(to_varchar(status)), '') as member_status,
        cast(null as varchar) as relationship_to_primary,
        'BJAZ_HAT_ID_MEM_DETLS' as record_source
    from {{ ref('stg_health__bjaz_hat_id_mem_detls') }}
    where contract_id is not null
    )

union all

select parent_bk, certificate_number_ck, certificate_number, coverage_end_date, coverage_start_date, enrolment_date, exit_reason, member_premium, member_status, relationship_to_primary, record_source from (
    select distinct
        contract_id as parent_bk,
        cast(null as varchar) as certificate_number_ck,
        cast(null as varchar) as certificate_number,
        nullif(trim(to_varchar(to_date)), '') as coverage_end_date,
        nullif(trim(to_varchar(from_date)), '') as coverage_start_date,
        cast(null as varchar) as enrolment_date,
        cast(null as varchar) as exit_reason,
        nullif(trim(to_varchar(premium)), '') as member_premium,
        cast(null as varchar) as member_status,
        cast(null as varchar) as relationship_to_primary,
        'BJAZ_HCF_MEMBER_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hcf_member_dtls') }}
    where contract_id is not null
    )

union all

select parent_bk, certificate_number_ck, certificate_number, coverage_end_date, coverage_start_date, enrolment_date, exit_reason, member_premium, member_status, relationship_to_primary, record_source from (
    select distinct
        contract_id as parent_bk,
        cast(null as varchar) as certificate_number_ck,
        cast(null as varchar) as certificate_number,
        cast(null as varchar) as coverage_end_date,
        cast(null as varchar) as coverage_start_date,
        cast(null as varchar) as enrolment_date,
        cast(null as varchar) as exit_reason,
        nullif(trim(to_varchar(premium)), '') as member_premium,
        cast(null as varchar) as member_status,
        cast(null as varchar) as relationship_to_primary,
        'BJAZ_HC_PART_EXTN' as record_source
    from {{ ref('stg_health__bjaz_hc_part_extn') }}
    where contract_id is not null
    )

union all

select parent_bk, certificate_number_ck, certificate_number, coverage_end_date, coverage_start_date, enrolment_date, exit_reason, member_premium, member_status, relationship_to_primary, record_source from (
    select distinct
        policy as parent_bk,
        cast(null as varchar) as certificate_number_ck,
        cast(null as varchar) as certificate_number,
        cast(null as varchar) as coverage_end_date,
        cast(null as varchar) as coverage_start_date,
        cast(null as varchar) as enrolment_date,
        cast(null as varchar) as exit_reason,
        nullif(trim(to_varchar(premium)), '') as member_premium,
        cast(null as varchar) as member_status,
        cast(null as varchar) as relationship_to_primary,
        'BJAZ_HM_HCM_EXTRACT' as record_source
    from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
    where policy is not null
    )

union all

select parent_bk, certificate_number_ck, certificate_number, coverage_end_date, coverage_start_date, enrolment_date, exit_reason, member_premium, member_status, relationship_to_primary, record_source from (
    select distinct
        contract_id as parent_bk,
        cast(null as varchar) as certificate_number_ck,
        cast(null as varchar) as certificate_number,
        cast(null as varchar) as coverage_end_date,
        cast(null as varchar) as coverage_start_date,
        cast(null as varchar) as enrolment_date,
        cast(null as varchar) as exit_reason,
        nullif(trim(to_varchar(premium)), '') as member_premium,
        nullif(trim(to_varchar(member_status)), '') as member_status,
        cast(null as varchar) as relationship_to_primary,
        'BJAZ_HM_MEMBER_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_member_dtls') }}
    where contract_id is not null
    )

union all

select parent_bk, certificate_number_ck, certificate_number, coverage_end_date, coverage_start_date, enrolment_date, exit_reason, member_premium, member_status, relationship_to_primary, record_source from (
    select distinct
        contract_id as parent_bk,
        cast(null as varchar) as certificate_number_ck,
        cast(null as varchar) as certificate_number,
        cast(null as varchar) as coverage_end_date,
        nullif(trim(to_varchar(effetive_date)), '') as coverage_start_date,
        cast(null as varchar) as enrolment_date,
        cast(null as varchar) as exit_reason,
        nullif(trim(to_varchar(premium)), '') as member_premium,
        cast(null as varchar) as member_status,
        cast(null as varchar) as relationship_to_primary,
        'BJAZ_IHG_MEM_DTLS_EXTN' as record_source
    from {{ ref('stg_health__bjaz_ihg_mem_dtls_extn') }}
    where contract_id is not null
    )

union all

select parent_bk, certificate_number_ck, certificate_number, coverage_end_date, coverage_start_date, enrolment_date, exit_reason, member_premium, member_status, relationship_to_primary, record_source from (
    select distinct
        contract_id as parent_bk,
        cast(null as varchar) as certificate_number_ck,
        cast(null as varchar) as certificate_number,
        cast(null as varchar) as coverage_end_date,
        nullif(trim(to_varchar(effetive_date)), '') as coverage_start_date,
        cast(null as varchar) as enrolment_date,
        cast(null as varchar) as exit_reason,
        nullif(trim(to_varchar(premium)), '') as member_premium,
        cast(null as varchar) as member_status,
        cast(null as varchar) as relationship_to_primary,
        'BJAZ_SH_MEM_DTLS_EXTN' as record_source
    from {{ ref('stg_health__bjaz_sh_mem_dtls_extn') }}
    where contract_id is not null
    )

)
