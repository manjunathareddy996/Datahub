-- Intermediate harmonisation view for SAT_POLICY_CLASSIFICATION (HUB_POLICY grain).
-- Stitched via a single source table, plus a UNION-appended fallback for 10 table(s) that lack the full multi-active child key.
-- record_source lists every table that actually contributed to a given row.
select * from (

select parent_bk, classification_type_ck, classification_value, record_source from (
    select distinct
        contract_id as parent_bk,
        cast(null as varchar) as classification_type_ck,
        nullif(trim(to_varchar(buss_type)), '') as classification_value,
        'BA_HCP_DT_PREMIUM' as record_source
    from {{ ref('stg_health__ba_hcp_dt_premium') }}
    where contract_id is not null
    )

union all

select parent_bk, classification_type_ck, classification_value, record_source from (
    select distinct
        pol_serial_no as parent_bk,
        cast(null as varchar) as classification_type_ck,
        nullif(trim(to_varchar(pd_business_type)), '') as classification_value,
        'BA_HCP_PROD_8428_GPG_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
    where pol_serial_no is not null
    )

union all

select parent_bk, classification_type_ck, classification_value, record_source from (
    select distinct
        pol_serial_no as parent_bk,
        cast(null as varchar) as classification_type_ck,
        nullif(trim(to_varchar(pd_business_type)), '') as classification_value,
        'BA_HCP_PROD_8432_ECP_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
    where pol_serial_no is not null
    )

union all

select parent_bk, classification_type_ck, classification_value, record_source from (
    select distinct
        pol_serial_no as parent_bk,
        cast(null as varchar) as classification_type_ck,
        nullif(trim(to_varchar(pd_business_type)), '') as classification_value,
        'BA_HCP_PROD_8433_FHC_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
    where pol_serial_no is not null
    )

union all

select parent_bk, classification_type_ck, classification_value, record_source from (
    select distinct
        pol_serial_no as parent_bk,
        cast(null as varchar) as classification_type_ck,
        nullif(trim(to_varchar(pd_business_type)), '') as classification_value,
        'BA_HCP_PROD_8439_CLH_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
    where pol_serial_no is not null
    )

union all

select parent_bk, classification_type_ck, classification_value, record_source from (
    select distinct
        policy_no as parent_bk,
        cast(null as varchar) as classification_type_ck,
        nullif(trim(to_varchar(grade_bucket)), '') as classification_value,
        'BGIL_GMC_FINAL_INSTL_DATA' as record_source
    from {{ ref('stg_health__bgil_gmc_final_instl_data') }}
    where policy_no is not null
    )

union all

select parent_bk, classification_type_ck, classification_value, record_source from (
    select distinct
        policy_ref as parent_bk,
        cast(null as varchar) as classification_type_ck,
        nullif(trim(to_varchar(business_type)), '') as classification_value,
        'BJAZ_BANDHAN_MEDI_CLAM' as record_source
    from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
    where policy_ref is not null
    )

union all

select parent_bk, classification_type_ck, classification_value, record_source from (
    select distinct
        reference_id as parent_bk,
        cast(null as varchar) as classification_type_ck,
        nullif(trim(to_varchar(business_type)), '') as classification_value,
        'BJAZ_GPG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
    where reference_id is not null
    )

union all

select parent_bk, classification_type_ck, classification_value, record_source from (
    select distinct
        reg_no as parent_bk,
        cast(null as varchar) as classification_type_ck,
        nullif(trim(to_varchar(industry_type)), '') as classification_value,
        'BJAZ_GRP_HLT_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
    where reg_no is not null
    )

union all

select parent_bk, classification_type_ck, classification_value, record_source from (
    select distinct
        policy_ref as parent_bk,
        cast(null as varchar) as classification_type_ck,
        nullif(trim(to_varchar(business_type)), '') as classification_value,
        'BJAZ_HEALTH_WEBSERVICE_INFO' as record_source
    from {{ ref('stg_health__bjaz_health_webservice_info') }}
    where policy_ref is not null
    )

)
