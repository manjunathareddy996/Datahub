-- Intermediate harmonisation view for SAT_POLICY_COVERAGE_SCHEDULE (HUB_POLICY grain).
-- Stitched via a single source table, plus a UNION-appended fallback for 6 table(s) that lack the full multi-active child key.
-- record_source lists every table that actually contributed to a given row.
select * from (

select parent_bk, coverage_reference_ck, coverage_sequence_ck, co_payment_amount, co_payment_percentage, coverage_opted_indicator, premium_for_coverage, sub_limit_amount, sum_insured, record_source from (
    select distinct
        contract_id as parent_bk,
        cast(null as varchar) as coverage_reference_ck,
        cast(null as varchar) as coverage_sequence_ck,
        cast(null as varchar) as co_payment_amount,
        cast(null as varchar) as co_payment_percentage,
        cast(null as varchar) as coverage_opted_indicator,
        nullif(trim(to_varchar(prem_base_cover)), '') as premium_for_coverage,
        cast(null as varchar) as sub_limit_amount,
        cast(null as varchar) as sum_insured,
        'BA_HCP_DT_POL_COV' as record_source
    from {{ ref('stg_health__ba_hcp_dt_pol_cov') }}
    where contract_id is not null
    )

union all

select parent_bk, coverage_reference_ck, coverage_sequence_ck, co_payment_amount, co_payment_percentage, coverage_opted_indicator, premium_for_coverage, sub_limit_amount, sum_insured, record_source from (
    select distinct
        pol_serial_no as parent_bk,
        cast(null as varchar) as coverage_reference_ck,
        cast(null as varchar) as coverage_sequence_ck,
        cast(null as varchar) as co_payment_amount,
        cast(null as varchar) as co_payment_percentage,
        nullif(trim(to_varchar(plac_air_ambulance_cover)), '') as coverage_opted_indicator,
        cast(null as varchar) as premium_for_coverage,
        cast(null as varchar) as sub_limit_amount,
        nullif(trim(to_varchar(plc_inpat_hosp_treat_si)), '') as sum_insured,
        'BA_HCP_PROD_8432_ECP_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
    where pol_serial_no is not null
    )

union all

select parent_bk, coverage_reference_ck, coverage_sequence_ck, co_payment_amount, co_payment_percentage, coverage_opted_indicator, premium_for_coverage, sub_limit_amount, sum_insured, record_source from (
    select distinct
        pol_serial_no as parent_bk,
        cast(null as varchar) as coverage_reference_ck,
        cast(null as varchar) as coverage_sequence_ck,
        cast(null as varchar) as co_payment_amount,
        cast(null as varchar) as co_payment_percentage,
        cast(null as varchar) as coverage_opted_indicator,
        cast(null as varchar) as premium_for_coverage,
        cast(null as varchar) as sub_limit_amount,
        nullif(trim(to_varchar(plc_inpat_hosp_treat_si)), '') as sum_insured,
        'BA_HCP_PROD_8433_FHC_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
    where pol_serial_no is not null
    )

union all

select parent_bk, coverage_reference_ck, coverage_sequence_ck, co_payment_amount, co_payment_percentage, coverage_opted_indicator, premium_for_coverage, sub_limit_amount, sum_insured, record_source from (
    select distinct
        reg_no as parent_bk,
        cast(null as varchar) as coverage_reference_ck,
        cast(null as varchar) as coverage_sequence_ck,
        cast(null as varchar) as co_payment_amount,
        cast(null as varchar) as co_payment_percentage,
        cast(null as varchar) as coverage_opted_indicator,
        cast(null as varchar) as premium_for_coverage,
        cast(null as varchar) as sub_limit_amount,
        nullif(trim(to_varchar(si_coverages)), '') as sum_insured,
        'BJAZ_GRP_HLT_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
    where reg_no is not null
    )

union all

select parent_bk, coverage_reference_ck, coverage_sequence_ck, co_payment_amount, co_payment_percentage, coverage_opted_indicator, premium_for_coverage, sub_limit_amount, sum_insured, record_source from (
    select distinct
        reg_no as parent_bk,
        cast(null as varchar) as coverage_reference_ck,
        cast(null as varchar) as coverage_sequence_ck,
        nullif(trim(to_varchar(maternity_copayment_amt)), '') as co_payment_amount,
        nullif(trim(to_varchar(maternity_copayment_per)), '') as co_payment_percentage,
        nullif(trim(to_varchar(out_patient_treatment)), '') as coverage_opted_indicator,
        cast(null as varchar) as premium_for_coverage,
        nullif(trim(to_varchar(maternity_benefit)), '') as sub_limit_amount,
        cast(null as varchar) as sum_insured,
        'BJAZ_GRP_HLT_MATERNITY_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_maternity_dtls') }}
    where reg_no is not null
    )

union all

select parent_bk, coverage_reference_ck, coverage_sequence_ck, co_payment_amount, co_payment_percentage, coverage_opted_indicator, premium_for_coverage, sub_limit_amount, sum_insured, record_source from (
    select distinct
        contract_id as parent_bk,
        cast(null as varchar) as coverage_reference_ck,
        cast(null as varchar) as coverage_sequence_ck,
        cast(null as varchar) as co_payment_amount,
        cast(null as varchar) as co_payment_percentage,
        nullif(trim(to_varchar(air_ambulance_yn)), '') as coverage_opted_indicator,
        cast(null as varchar) as premium_for_coverage,
        cast(null as varchar) as sub_limit_amount,
        cast(null as varchar) as sum_insured,
        'BJAZ_HG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
    where contract_id is not null
    )

)
