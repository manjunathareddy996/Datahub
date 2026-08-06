-- Intermediate harmonisation view for SAT_COMMON_CONTACT (HUB_PARTY grain).
-- Stitched via a single source table, plus a UNION-appended fallback for 16 table(s) that lack the full multi-active child key.
-- record_source lists every table that actually contributed to a given row.
select * from (

select parent_bk, contact_point_type_ck, contact_priority_order_ck, alternate_email_address, alternate_mobile_number, email_address, fax_number, landline_number, mobile_number, std_code, record_source from (
    select distinct
        alloted_to as parent_bk,
        cast(null as varchar) as contact_point_type_ck,
        cast(null as varchar) as contact_priority_order_ck,
        cast(null as varchar) as alternate_email_address,
        cast(null as varchar) as alternate_mobile_number,
        cast(null as varchar) as email_address,
        cast(null as varchar) as fax_number,
        nullif(trim(to_varchar(dc_teleno)), '') as landline_number,
        cast(null as varchar) as mobile_number,
        cast(null as varchar) as std_code,
        'BA_HCP_PP_MEM_DTLS' as record_source
    from {{ ref('stg_health__ba_hcp_pp_mem_dtls') }}
    where alloted_to is not null
    )

union all

select parent_bk, contact_point_type_ck, contact_priority_order_ck, alternate_email_address, alternate_mobile_number, email_address, fax_number, landline_number, mobile_number, std_code, record_source from (
    select distinct
        pd_premium_payer_id as parent_bk,
        cast(null as varchar) as contact_point_type_ck,
        cast(null as varchar) as contact_priority_order_ck,
        cast(null as varchar) as alternate_email_address,
        cast(null as varchar) as alternate_mobile_number,
        nullif(trim(to_varchar(pd_email)), '') as email_address,
        nullif(trim(to_varchar(pd_fax)), '') as fax_number,
        nullif(trim(to_varchar(pd_telephone)), '') as landline_number,
        nullif(trim(to_varchar(pd_mobile_number)), '') as mobile_number,
        cast(null as varchar) as std_code,
        'BA_HCP_PROD_8428_GPG_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
    where pd_premium_payer_id is not null
    )

union all

select parent_bk, contact_point_type_ck, contact_priority_order_ck, alternate_email_address, alternate_mobile_number, email_address, fax_number, landline_number, mobile_number, std_code, record_source from (
    select distinct
        pd_premium_payer_id as parent_bk,
        cast(null as varchar) as contact_point_type_ck,
        cast(null as varchar) as contact_priority_order_ck,
        cast(null as varchar) as alternate_email_address,
        cast(null as varchar) as alternate_mobile_number,
        nullif(trim(to_varchar(pd_email)), '') as email_address,
        nullif(trim(to_varchar(pd_fax)), '') as fax_number,
        nullif(trim(to_varchar(pd_telephone)), '') as landline_number,
        nullif(trim(to_varchar(pd_mobile_number)), '') as mobile_number,
        cast(null as varchar) as std_code,
        'BA_HCP_PROD_8432_ECP_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
    where pd_premium_payer_id is not null
    )

union all

select parent_bk, contact_point_type_ck, contact_priority_order_ck, alternate_email_address, alternate_mobile_number, email_address, fax_number, landline_number, mobile_number, std_code, record_source from (
    select distinct
        pd_premium_payer_id as parent_bk,
        cast(null as varchar) as contact_point_type_ck,
        cast(null as varchar) as contact_priority_order_ck,
        cast(null as varchar) as alternate_email_address,
        cast(null as varchar) as alternate_mobile_number,
        nullif(trim(to_varchar(pd_email)), '') as email_address,
        nullif(trim(to_varchar(pd_fax)), '') as fax_number,
        nullif(trim(to_varchar(pd_telephone)), '') as landline_number,
        nullif(trim(to_varchar(pd_mobile_number)), '') as mobile_number,
        cast(null as varchar) as std_code,
        'BA_HCP_PROD_8433_FHC_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
    where pd_premium_payer_id is not null
    )

union all

select parent_bk, contact_point_type_ck, contact_priority_order_ck, alternate_email_address, alternate_mobile_number, email_address, fax_number, landline_number, mobile_number, std_code, record_source from (
    select distinct
        pd_premium_payer_id as parent_bk,
        cast(null as varchar) as contact_point_type_ck,
        cast(null as varchar) as contact_priority_order_ck,
        cast(null as varchar) as alternate_email_address,
        cast(null as varchar) as alternate_mobile_number,
        nullif(trim(to_varchar(pd_email)), '') as email_address,
        nullif(trim(to_varchar(pd_fax)), '') as fax_number,
        nullif(trim(to_varchar(pd_telephone)), '') as landline_number,
        nullif(trim(to_varchar(pd_mobile_number)), '') as mobile_number,
        cast(null as varchar) as std_code,
        'BA_HCP_PROD_8439_CLH_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
    where pd_premium_payer_id is not null
    )

union all

select parent_bk, contact_point_type_ck, contact_priority_order_ck, alternate_email_address, alternate_mobile_number, email_address, fax_number, landline_number, mobile_number, std_code, record_source from (
    select distinct
        customer_id as parent_bk,
        cast(null as varchar) as contact_point_type_ck,
        cast(null as varchar) as contact_priority_order_ck,
        nullif(trim(to_varchar(m_email)), '') as alternate_email_address,
        nullif(trim(to_varchar(m_mobile)), '') as alternate_mobile_number,
        nullif(trim(to_varchar(p_email)), '') as email_address,
        cast(null as varchar) as fax_number,
        cast(null as varchar) as landline_number,
        nullif(trim(to_varchar(mobile)), '') as mobile_number,
        cast(null as varchar) as std_code,
        'BJAZ_BANDHAN_MEDI_CLAM' as record_source
    from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
    where customer_id is not null
    )

union all

select parent_bk, contact_point_type_ck, contact_priority_order_ck, alternate_email_address, alternate_mobile_number, email_address, fax_number, landline_number, mobile_number, std_code, record_source from (
    select distinct
        member_no as parent_bk,
        cast(null as varchar) as contact_point_type_ck,
        cast(null as varchar) as contact_priority_order_ck,
        cast(null as varchar) as alternate_email_address,
        cast(null as varchar) as alternate_mobile_number,
        nullif(trim(to_varchar(email_id)), '') as email_address,
        cast(null as varchar) as fax_number,
        nullif(trim(to_varchar(tel)), '') as landline_number,
        cast(null as varchar) as mobile_number,
        cast(null as varchar) as std_code,
        'BJAZ_HAT_ID_MEM_DETLS' as record_source
    from {{ ref('stg_health__bjaz_hat_id_mem_detls') }}
    where member_no is not null
    )

union all

select parent_bk, contact_point_type_ck, contact_priority_order_ck, alternate_email_address, alternate_mobile_number, email_address, fax_number, landline_number, mobile_number, std_code, record_source from (
    select distinct
        part_id as parent_bk,
        cast(null as varchar) as contact_point_type_ck,
        cast(null as varchar) as contact_priority_order_ck,
        nullif(trim(to_varchar(email_cust)), '') as alternate_email_address,
        cast(null as varchar) as alternate_mobile_number,
        nullif(trim(to_varchar(email)), '') as email_address,
        cast(null as varchar) as fax_number,
        nullif(trim(to_varchar(telephone)), '') as landline_number,
        nullif(trim(to_varchar(mobile_no)), '') as mobile_number,
        cast(null as varchar) as std_code,
        'BJAZ_HG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
    where part_id is not null
    )

union all

select parent_bk, contact_point_type_ck, contact_priority_order_ck, alternate_email_address, alternate_mobile_number, email_address, fax_number, landline_number, mobile_number, std_code, record_source from (
    select distinct
        hospital_id as parent_bk,
        cast(null as varchar) as contact_point_type_ck,
        cast(null as varchar) as contact_priority_order_ck,
        cast(null as varchar) as alternate_email_address,
        cast(null as varchar) as alternate_mobile_number,
        cast(null as varchar) as email_address,
        nullif(trim(to_varchar(fax)), '') as fax_number,
        nullif(trim(to_varchar(phone)), '') as landline_number,
        nullif(trim(to_varchar(mobile_no)), '') as mobile_number,
        nullif(trim(to_varchar(std)), '') as std_code,
        'BJAZ_HM_HCM_EXTRACT' as record_source
    from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
    where hospital_id is not null
    )

union all

select parent_bk, contact_point_type_ck, contact_priority_order_ck, alternate_email_address, alternate_mobile_number, email_address, fax_number, landline_number, mobile_number, std_code, record_source from (
    select distinct
        hosid as parent_bk,
        cast(null as varchar) as contact_point_type_ck,
        cast(null as varchar) as contact_priority_order_ck,
        cast(null as varchar) as alternate_email_address,
        cast(null as varchar) as alternate_mobile_number,
        nullif(trim(to_varchar(email)), '') as email_address,
        nullif(trim(to_varchar(fax_no)), '') as fax_number,
        nullif(trim(to_varchar(phone_no)), '') as landline_number,
        cast(null as varchar) as mobile_number,
        nullif(trim(to_varchar(std_code)), '') as std_code,
        'BJAZ_HM_HOSPITAL_MASTER' as record_source
    from {{ ref('stg_health__bjaz_hm_hospital_master') }}
    where hosid is not null
    )

union all

select parent_bk, contact_point_type_ck, contact_priority_order_ck, alternate_email_address, alternate_mobile_number, email_address, fax_number, landline_number, mobile_number, std_code, record_source from (
    select distinct
        hosid as parent_bk,
        cast(null as varchar) as contact_point_type_ck,
        cast(null as varchar) as contact_priority_order_ck,
        cast(null as varchar) as alternate_email_address,
        cast(null as varchar) as alternate_mobile_number,
        nullif(trim(to_varchar(email_fin_dept)), '') as email_address,
        nullif(trim(to_varchar(fax_no2)), '') as fax_number,
        nullif(trim(to_varchar(phone_no2)), '') as landline_number,
        nullif(trim(to_varchar(mobile_no)), '') as mobile_number,
        cast(null as varchar) as std_code,
        'BJAZ_HM_HOSPITAL_MASTER_EXTN' as record_source
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where hosid is not null
    )

union all

select parent_bk, contact_point_type_ck, contact_priority_order_ck, alternate_email_address, alternate_mobile_number, email_address, fax_number, landline_number, mobile_number, std_code, record_source from (
    select distinct
        hosid as parent_bk,
        cast(null as varchar) as contact_point_type_ck,
        cast(null as varchar) as contact_priority_order_ck,
        cast(null as varchar) as alternate_email_address,
        cast(null as varchar) as alternate_mobile_number,
        nullif(trim(to_varchar(tpaemail)), '') as email_address,
        cast(null as varchar) as fax_number,
        cast(null as varchar) as landline_number,
        nullif(trim(to_varchar(billingmobileno)), '') as mobile_number,
        cast(null as varchar) as std_code,
        'BJAZ_HM_HOSP_MASTER_EXTN1' as record_source
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where hosid is not null
    )

union all

select parent_bk, contact_point_type_ck, contact_priority_order_ck, alternate_email_address, alternate_mobile_number, email_address, fax_number, landline_number, mobile_number, std_code, record_source from (
    select distinct
        courier_id as parent_bk,
        cast(null as varchar) as contact_point_type_ck,
        cast(null as varchar) as contact_priority_order_ck,
        cast(null as varchar) as alternate_email_address,
        cast(null as varchar) as alternate_mobile_number,
        nullif(trim(to_varchar(email_id)), '') as email_address,
        cast(null as varchar) as fax_number,
        cast(null as varchar) as landline_number,
        nullif(trim(to_varchar(caller_contact_no)), '') as mobile_number,
        cast(null as varchar) as std_code,
        'BJAZ_HM_INWARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_inward_dtls') }}
    where courier_id is not null
    )

union all

select parent_bk, contact_point_type_ck, contact_priority_order_ck, alternate_email_address, alternate_mobile_number, email_address, fax_number, landline_number, mobile_number, std_code, record_source from (
    select distinct
        member_id as parent_bk,
        cast(null as varchar) as contact_point_type_ck,
        cast(null as varchar) as contact_priority_order_ck,
        cast(null as varchar) as alternate_email_address,
        cast(null as varchar) as alternate_mobile_number,
        nullif(trim(to_varchar(email_id)), '') as email_address,
        cast(null as varchar) as fax_number,
        nullif(trim(to_varchar(phone_no)), '') as landline_number,
        cast(null as varchar) as mobile_number,
        cast(null as varchar) as std_code,
        'BJAZ_HM_MEMBER_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_member_dtls') }}
    where member_id is not null
    )

union all

select parent_bk, contact_point_type_ck, contact_priority_order_ck, alternate_email_address, alternate_mobile_number, email_address, fax_number, landline_number, mobile_number, std_code, record_source from (
    select distinct
        member_no as parent_bk,
        cast(null as varchar) as contact_point_type_ck,
        cast(null as varchar) as contact_priority_order_ck,
        cast(null as varchar) as alternate_email_address,
        cast(null as varchar) as alternate_mobile_number,
        nullif(trim(to_varchar(email_id)), '') as email_address,
        cast(null as varchar) as fax_number,
        cast(null as varchar) as landline_number,
        cast(null as varchar) as mobile_number,
        cast(null as varchar) as std_code,
        'BJAZ_SH_MEM_DTLS_EXTN' as record_source
    from {{ ref('stg_health__bjaz_sh_mem_dtls_extn') }}
    where member_no is not null
    )

union all

select parent_bk, contact_point_type_ck, contact_priority_order_ck, alternate_email_address, alternate_mobile_number, email_address, fax_number, landline_number, mobile_number, std_code, record_source from (
    select distinct
        customer_id as parent_bk,
        cast(null as varchar) as contact_point_type_ck,
        cast(null as varchar) as contact_priority_order_ck,
        cast(null as varchar) as alternate_email_address,
        cast(null as varchar) as alternate_mobile_number,
        nullif(trim(to_varchar(email_id_1)), '') as email_address,
        cast(null as varchar) as fax_number,
        cast(null as varchar) as landline_number,
        nullif(trim(to_varchar(mob_no)), '') as mobile_number,
        cast(null as varchar) as std_code,
        'BJAZ_TPA_CLAIM_DETAILS_WS' as record_source
    from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
    where customer_id is not null
    )

)
