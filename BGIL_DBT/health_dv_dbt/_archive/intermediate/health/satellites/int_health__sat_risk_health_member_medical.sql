-- Intermediate harmonisation view for SAT_RISK_HEALTH_MEMBER_MEDICAL (HUB_RISK_OBJECT grain).
-- Stitched via a single source table, plus a UNION-appended fallback for 4 table(s) that lack the full multi-active child key.
-- record_source lists every table that actually contributed to a given row.
select * from (

select parent_bk, member_reference_ck, condition_name, date_of_marriage, disclosed_indicator, last_treatment_date, number_of_daughters, underwriting_loading_percentage, record_source from (
    select distinct
        pol_serial_no || '|' || md_seq_no as parent_bk,
        cast(null as varchar) as member_reference_ck,
        cast(null as varchar) as condition_name,
        cast(null as varchar) as date_of_marriage,
        nullif(trim(to_varchar(md_asthma)), '') as disclosed_indicator,
        cast(null as varchar) as last_treatment_date,
        cast(null as varchar) as number_of_daughters,
        cast(null as varchar) as underwriting_loading_percentage,
        'BA_HCP_PROD_8433_FHC_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
    where pol_serial_no is not null and md_seq_no is not null
    )

union all

select parent_bk, member_reference_ck, condition_name, date_of_marriage, disclosed_indicator, last_treatment_date, number_of_daughters, underwriting_loading_percentage, record_source from (
    select distinct
        contract_id || '|' || member_ref_number as parent_bk,
        cast(null as varchar) as member_reference_ck,
        nullif(trim(to_varchar(pre_exist_disease)), '') as condition_name,
        cast(null as varchar) as date_of_marriage,
        cast(null as varchar) as disclosed_indicator,
        cast(null as varchar) as last_treatment_date,
        cast(null as varchar) as number_of_daughters,
        cast(null as varchar) as underwriting_loading_percentage,
        'BJAZ_CTNGY_PA_MEM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ctngy_pa_mem_dtls') }}
    where contract_id is not null and member_ref_number is not null
    )

union all

select parent_bk, member_reference_ck, condition_name, date_of_marriage, disclosed_indicator, last_treatment_date, number_of_daughters, underwriting_loading_percentage, record_source from (
    select distinct
        contract_id || '|' || member_no as parent_bk,
        cast(null as varchar) as member_reference_ck,
        nullif(trim(to_varchar(past_4yr_illness)), '') as condition_name,
        cast(null as varchar) as date_of_marriage,
        nullif(trim(to_varchar(diabetes_yn)), '') as disclosed_indicator,
        nullif(trim(to_varchar(past_4yr_treat_date)), '') as last_treatment_date,
        cast(null as varchar) as number_of_daughters,
        cast(null as varchar) as underwriting_loading_percentage,
        'BJAZ_EC_MEM_DTLS_EXTN' as record_source
    from {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
    where contract_id is not null and member_no is not null
    )

union all

select parent_bk, member_reference_ck, condition_name, date_of_marriage, disclosed_indicator, last_treatment_date, number_of_daughters, underwriting_loading_percentage, record_source from (
    select distinct
        contract_id || '|' || member_no as parent_bk,
        cast(null as varchar) as member_reference_ck,
        nullif(trim(to_varchar(preexist_dicease)), '') as condition_name,
        cast(null as varchar) as date_of_marriage,
        nullif(trim(to_varchar(asthma_flag)), '') as disclosed_indicator,
        cast(null as varchar) as last_treatment_date,
        cast(null as varchar) as number_of_daughters,
        nullif(trim(to_varchar(obesity_load)), '') as underwriting_loading_percentage,
        'BJAZ_HCF_MEMBER_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hcf_member_dtls') }}
    where contract_id is not null and member_no is not null
    )

)
