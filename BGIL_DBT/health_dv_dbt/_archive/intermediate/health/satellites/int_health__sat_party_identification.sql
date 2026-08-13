-- Intermediate harmonisation view for SAT_PARTY_IDENTIFICATION (HUB_PARTY grain).
-- Stitched via a single source table, plus a UNION-appended fallback for 16 table(s) that lack the full multi-active child key.
-- record_source lists every table that actually contributed to a given row.
select * from (

select parent_bk, identification_type_code_ck, aadhaar_number, aadhaar_verification_status, age_proof_type, eia_number, gstin, identification_number, pan_number, pan_verification_status, passport_number, tan_number, record_source from (
    select distinct
        pd_premium_payer_id as parent_bk,
        cast(null as varchar) as identification_type_code_ck,
        nullif(trim(to_varchar(pd_adhar_card_no)), '') as aadhaar_number,
        cast(null as varchar) as aadhaar_verification_status,
        cast(null as varchar) as age_proof_type,
        nullif(trim(to_varchar(pd_electronic_insur_account_no)), '') as eia_number,
        nullif(trim(to_varchar(gstin_uin)), '') as gstin,
        nullif(trim(to_varchar(pd_bank_ref_no2_bank_cust_id)), '') as identification_number,
        nullif(trim(to_varchar(pd_pan_no)), '') as pan_number,
        cast(null as varchar) as pan_verification_status,
        cast(null as varchar) as passport_number,
        cast(null as varchar) as tan_number,
        'BA_HCP_PROD_8428_GPG_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
    where pd_premium_payer_id is not null
    )

union all

select parent_bk, identification_type_code_ck, aadhaar_number, aadhaar_verification_status, age_proof_type, eia_number, gstin, identification_number, pan_number, pan_verification_status, passport_number, tan_number, record_source from (
    select distinct
        pd_premium_payer_id as parent_bk,
        cast(null as varchar) as identification_type_code_ck,
        nullif(trim(to_varchar(pd_adhar_card_no)), '') as aadhaar_number,
        cast(null as varchar) as aadhaar_verification_status,
        cast(null as varchar) as age_proof_type,
        nullif(trim(to_varchar(pd_electronic_insur_account_no)), '') as eia_number,
        nullif(trim(to_varchar(gstin_uin)), '') as gstin,
        cast(null as varchar) as identification_number,
        nullif(trim(to_varchar(pd_pan_no)), '') as pan_number,
        cast(null as varchar) as pan_verification_status,
        cast(null as varchar) as passport_number,
        cast(null as varchar) as tan_number,
        'BA_HCP_PROD_8432_ECP_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
    where pd_premium_payer_id is not null
    )

union all

select parent_bk, identification_type_code_ck, aadhaar_number, aadhaar_verification_status, age_proof_type, eia_number, gstin, identification_number, pan_number, pan_verification_status, passport_number, tan_number, record_source from (
    select distinct
        pd_premium_payer_id as parent_bk,
        cast(null as varchar) as identification_type_code_ck,
        nullif(trim(to_varchar(pd_adhar_card_no)), '') as aadhaar_number,
        cast(null as varchar) as aadhaar_verification_status,
        cast(null as varchar) as age_proof_type,
        nullif(trim(to_varchar(pd_electronic_insur_account_no)), '') as eia_number,
        nullif(trim(to_varchar(gstin_uin)), '') as gstin,
        cast(null as varchar) as identification_number,
        nullif(trim(to_varchar(pd_pan_no)), '') as pan_number,
        cast(null as varchar) as pan_verification_status,
        cast(null as varchar) as passport_number,
        cast(null as varchar) as tan_number,
        'BA_HCP_PROD_8433_FHC_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
    where pd_premium_payer_id is not null
    )

union all

select parent_bk, identification_type_code_ck, aadhaar_number, aadhaar_verification_status, age_proof_type, eia_number, gstin, identification_number, pan_number, pan_verification_status, passport_number, tan_number, record_source from (
    select distinct
        pd_premium_payer_id as parent_bk,
        cast(null as varchar) as identification_type_code_ck,
        nullif(trim(to_varchar(pd_a_card_no)), '') as aadhaar_number,
        cast(null as varchar) as aadhaar_verification_status,
        cast(null as varchar) as age_proof_type,
        nullif(trim(to_varchar(pd_electronic_insur_account_no)), '') as eia_number,
        nullif(trim(to_varchar(gstin_uin)), '') as gstin,
        cast(null as varchar) as identification_number,
        nullif(trim(to_varchar(pd_pan_no)), '') as pan_number,
        cast(null as varchar) as pan_verification_status,
        cast(null as varchar) as passport_number,
        cast(null as varchar) as tan_number,
        'BA_HCP_PROD_8439_CLH_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
    where pd_premium_payer_id is not null
    )

union all

select parent_bk, identification_type_code_ck, aadhaar_number, aadhaar_verification_status, age_proof_type, eia_number, gstin, identification_number, pan_number, pan_verification_status, passport_number, tan_number, record_source from (
    select distinct
        customer_id as parent_bk,
        cast(null as varchar) as identification_type_code_ck,
        nullif(trim(to_varchar(aadhaar_number)), '') as aadhaar_number,
        cast(null as varchar) as aadhaar_verification_status,
        cast(null as varchar) as age_proof_type,
        cast(null as varchar) as eia_number,
        nullif(trim(to_varchar(gst_reg_no)), '') as gstin,
        cast(null as varchar) as identification_number,
        nullif(trim(to_varchar(pan_no)), '') as pan_number,
        cast(null as varchar) as pan_verification_status,
        cast(null as varchar) as passport_number,
        cast(null as varchar) as tan_number,
        'BJAZ_BANDHAN_MEDI_CLAM' as record_source
    from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
    where customer_id is not null
    )

union all

select parent_bk, identification_type_code_ck, aadhaar_number, aadhaar_verification_status, age_proof_type, eia_number, gstin, identification_number, pan_number, pan_verification_status, passport_number, tan_number, record_source from (
    select distinct
        member_no as parent_bk,
        cast(null as varchar) as identification_type_code_ck,
        cast(null as varchar) as aadhaar_number,
        cast(null as varchar) as aadhaar_verification_status,
        nullif(trim(to_varchar(age_proof)), '') as age_proof_type,
        cast(null as varchar) as eia_number,
        cast(null as varchar) as gstin,
        cast(null as varchar) as identification_number,
        cast(null as varchar) as pan_number,
        cast(null as varchar) as pan_verification_status,
        cast(null as varchar) as passport_number,
        cast(null as varchar) as tan_number,
        'BJAZ_EC_MEM_DTLS_EXTN' as record_source
    from {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
    where member_no is not null
    )

union all

select parent_bk, identification_type_code_ck, aadhaar_number, aadhaar_verification_status, age_proof_type, eia_number, gstin, identification_number, pan_number, pan_verification_status, passport_number, tan_number, record_source from (
    select distinct
        bagic_e_code as parent_bk,
        cast(null as varchar) as identification_type_code_ck,
        cast(null as varchar) as aadhaar_number,
        cast(null as varchar) as aadhaar_verification_status,
        cast(null as varchar) as age_proof_type,
        cast(null as varchar) as eia_number,
        nullif(trim(to_varchar(partner_gstn)), '') as gstin,
        cast(null as varchar) as identification_number,
        cast(null as varchar) as pan_number,
        cast(null as varchar) as pan_verification_status,
        cast(null as varchar) as passport_number,
        cast(null as varchar) as tan_number,
        'BJAZ_GPG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
    where bagic_e_code is not null
    )

union all

select parent_bk, identification_type_code_ck, aadhaar_number, aadhaar_verification_status, age_proof_type, eia_number, gstin, identification_number, pan_number, pan_verification_status, passport_number, tan_number, record_source from (
    select distinct
        part_id as parent_bk,
        cast(null as varchar) as identification_type_code_ck,
        nullif(trim(to_varchar(aadhaar_no)), '') as aadhaar_number,
        cast(null as varchar) as aadhaar_verification_status,
        cast(null as varchar) as age_proof_type,
        cast(null as varchar) as eia_number,
        nullif(trim(to_varchar(partner_gstn)), '') as gstin,
        cast(null as varchar) as identification_number,
        nullif(trim(to_varchar(pan_number)), '') as pan_number,
        cast(null as varchar) as pan_verification_status,
        cast(null as varchar) as passport_number,
        cast(null as varchar) as tan_number,
        'BJAZ_HG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
    where part_id is not null
    )

union all

select parent_bk, identification_type_code_ck, aadhaar_number, aadhaar_verification_status, age_proof_type, eia_number, gstin, identification_number, pan_number, pan_verification_status, passport_number, tan_number, record_source from (
    select distinct
        member_no as parent_bk,
        cast(null as varchar) as identification_type_code_ck,
        cast(null as varchar) as aadhaar_number,
        cast(null as varchar) as aadhaar_verification_status,
        nullif(trim(to_varchar(age_proof_yn)), '') as age_proof_type,
        cast(null as varchar) as eia_number,
        cast(null as varchar) as gstin,
        cast(null as varchar) as identification_number,
        cast(null as varchar) as pan_number,
        cast(null as varchar) as pan_verification_status,
        cast(null as varchar) as passport_number,
        cast(null as varchar) as tan_number,
        'BJAZ_HLT_ENSURE_MEM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hlt_ensure_mem_dtls') }}
    where member_no is not null
    )

union all

select parent_bk, identification_type_code_ck, aadhaar_number, aadhaar_verification_status, age_proof_type, eia_number, gstin, identification_number, pan_number, pan_verification_status, passport_number, tan_number, record_source from (
    select distinct
        hospital_id as parent_bk,
        cast(null as varchar) as identification_type_code_ck,
        cast(null as varchar) as aadhaar_number,
        cast(null as varchar) as aadhaar_verification_status,
        cast(null as varchar) as age_proof_type,
        cast(null as varchar) as eia_number,
        cast(null as varchar) as gstin,
        nullif(trim(to_varchar(id_card)), '') as identification_number,
        nullif(trim(to_varchar(pan_no)), '') as pan_number,
        cast(null as varchar) as pan_verification_status,
        cast(null as varchar) as passport_number,
        cast(null as varchar) as tan_number,
        'BJAZ_HM_HCM_EXTRACT' as record_source
    from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
    where hospital_id is not null
    )

union all

select parent_bk, identification_type_code_ck, aadhaar_number, aadhaar_verification_status, age_proof_type, eia_number, gstin, identification_number, pan_number, pan_verification_status, passport_number, tan_number, record_source from (
    select distinct
        hosid as parent_bk,
        cast(null as varchar) as identification_type_code_ck,
        cast(null as varchar) as aadhaar_number,
        cast(null as varchar) as aadhaar_verification_status,
        cast(null as varchar) as age_proof_type,
        cast(null as varchar) as eia_number,
        cast(null as varchar) as gstin,
        nullif(trim(to_varchar(stax_reg_no)), '') as identification_number,
        cast(null as varchar) as pan_number,
        cast(null as varchar) as pan_verification_status,
        cast(null as varchar) as passport_number,
        cast(null as varchar) as tan_number,
        'BJAZ_HM_HOSPITAL_MASTER' as record_source
    from {{ ref('stg_health__bjaz_hm_hospital_master') }}
    where hosid is not null
    )

union all

select parent_bk, identification_type_code_ck, aadhaar_number, aadhaar_verification_status, age_proof_type, eia_number, gstin, identification_number, pan_number, pan_verification_status, passport_number, tan_number, record_source from (
    select distinct
        hosid as parent_bk,
        cast(null as varchar) as identification_type_code_ck,
        cast(null as varchar) as aadhaar_number,
        cast(null as varchar) as aadhaar_verification_status,
        cast(null as varchar) as age_proof_type,
        cast(null as varchar) as eia_number,
        cast(null as varchar) as gstin,
        nullif(trim(to_varchar(irda_unique_id)), '') as identification_number,
        cast(null as varchar) as pan_number,
        cast(null as varchar) as pan_verification_status,
        cast(null as varchar) as passport_number,
        nullif(trim(to_varchar(tan_no)), '') as tan_number,
        'BJAZ_HM_HOSPITAL_MASTER_EXTN' as record_source
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where hosid is not null
    )

union all

select parent_bk, identification_type_code_ck, aadhaar_number, aadhaar_verification_status, age_proof_type, eia_number, gstin, identification_number, pan_number, pan_verification_status, passport_number, tan_number, record_source from (
    select distinct
        courier_id as parent_bk,
        cast(null as varchar) as identification_type_code_ck,
        cast(null as varchar) as aadhaar_number,
        cast(null as varchar) as aadhaar_verification_status,
        cast(null as varchar) as age_proof_type,
        cast(null as varchar) as eia_number,
        cast(null as varchar) as gstin,
        cast(null as varchar) as identification_number,
        cast(null as varchar) as pan_number,
        cast(null as varchar) as pan_verification_status,
        nullif(trim(to_varchar(passport_no)), '') as passport_number,
        cast(null as varchar) as tan_number,
        'BJAZ_HM_INWARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_inward_dtls') }}
    where courier_id is not null
    )

union all

select parent_bk, identification_type_code_ck, aadhaar_number, aadhaar_verification_status, age_proof_type, eia_number, gstin, identification_number, pan_number, pan_verification_status, passport_number, tan_number, record_source from (
    select distinct
        member_no as parent_bk,
        cast(null as varchar) as identification_type_code_ck,
        cast(null as varchar) as aadhaar_number,
        cast(null as varchar) as aadhaar_verification_status,
        nullif(trim(to_varchar(age_proof)), '') as age_proof_type,
        cast(null as varchar) as eia_number,
        cast(null as varchar) as gstin,
        cast(null as varchar) as identification_number,
        cast(null as varchar) as pan_number,
        cast(null as varchar) as pan_verification_status,
        cast(null as varchar) as passport_number,
        cast(null as varchar) as tan_number,
        'BJAZ_IHG_MEM_DTLS_EXTN' as record_source
    from {{ ref('stg_health__bjaz_ihg_mem_dtls_extn') }}
    where member_no is not null
    )

union all

select parent_bk, identification_type_code_ck, aadhaar_number, aadhaar_verification_status, age_proof_type, eia_number, gstin, identification_number, pan_number, pan_verification_status, passport_number, tan_number, record_source from (
    select distinct
        payer_code as parent_bk,
        cast(null as varchar) as identification_type_code_ck,
        cast(null as varchar) as aadhaar_number,
        cast(null as varchar) as aadhaar_verification_status,
        cast(null as varchar) as age_proof_type,
        cast(null as varchar) as eia_number,
        cast(null as varchar) as gstin,
        nullif(trim(to_varchar(irda_id)), '') as identification_number,
        cast(null as varchar) as pan_number,
        cast(null as varchar) as pan_verification_status,
        cast(null as varchar) as passport_number,
        cast(null as varchar) as tan_number,
        'BJAZ_REMEDINET_CLAIM_DETAILS' as record_source
    from {{ ref('stg_health__bjaz_remedinet_claim_details') }}
    where payer_code is not null
    )

union all

select parent_bk, identification_type_code_ck, aadhaar_number, aadhaar_verification_status, age_proof_type, eia_number, gstin, identification_number, pan_number, pan_verification_status, passport_number, tan_number, record_source from (
    select distinct
        customer_id as parent_bk,
        cast(null as varchar) as identification_type_code_ck,
        cast(null as varchar) as aadhaar_number,
        cast(null as varchar) as aadhaar_verification_status,
        cast(null as varchar) as age_proof_type,
        cast(null as varchar) as eia_number,
        cast(null as varchar) as gstin,
        cast(null as varchar) as identification_number,
        nullif(trim(to_varchar(pan_no)), '') as pan_number,
        cast(null as varchar) as pan_verification_status,
        cast(null as varchar) as passport_number,
        cast(null as varchar) as tan_number,
        'BJAZ_TPA_CLAIM_DETAILS_WS' as record_source
    from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
    where customer_id is not null
    )

)
