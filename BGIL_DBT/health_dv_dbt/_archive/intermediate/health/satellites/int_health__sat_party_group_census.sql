-- Intermediate harmonisation view for SAT_PARTY_GROUP_CENSUS (HUB_PARTY grain).
-- Stitched via a single source table, plus a UNION-appended fallback for 8 table(s) that lack the full multi-active child key.
-- record_source lists every table that actually contributed to a given row.
select * from (

select parent_bk, member_reference_ck, active_indicator, date_of_joining, designation_band, employee_id, location_reference, member_name, record_source from (
    select distinct
        emp_code as parent_bk,
        cast(null as varchar) as member_reference_ck,
        cast(null as varchar) as active_indicator,
        nullif(trim(to_varchar(doj)), '') as date_of_joining,
        nullif(trim(to_varchar(grade_code)), '') as designation_band,
        cast(null as varchar) as employee_id,
        cast(null as varchar) as location_reference,
        cast(null as varchar) as member_name,
        'BGIL_GMC_FINAL_INSTL_DATA' as record_source
    from {{ ref('stg_health__bgil_gmc_final_instl_data') }}
    where emp_code is not null
    )

union all

select parent_bk, member_reference_ck, active_indicator, date_of_joining, designation_band, employee_id, location_reference, member_name, record_source from (
    select distinct
        emp_code as parent_bk,
        cast(null as varchar) as member_reference_ck,
        cast(null as varchar) as active_indicator,
        cast(null as varchar) as date_of_joining,
        cast(null as varchar) as designation_band,
        cast(null as varchar) as employee_id,
        cast(null as varchar) as location_reference,
        nullif(trim(to_varchar(emp_neme)), '') as member_name,
        'BJAZ_ECARD_MEMBR_DEL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ecard_membr_del_dtls') }}
    where emp_code is not null
    )

union all

select parent_bk, member_reference_ck, active_indicator, date_of_joining, designation_band, employee_id, location_reference, member_name, record_source from (
    select distinct
        member_no as parent_bk,
        cast(null as varchar) as member_reference_ck,
        cast(null as varchar) as active_indicator,
        cast(null as varchar) as date_of_joining,
        cast(null as varchar) as designation_band,
        nullif(trim(to_varchar(emp_no)), '') as employee_id,
        cast(null as varchar) as location_reference,
        cast(null as varchar) as member_name,
        'BJAZ_HAT_ID_MEM_DETLS' as record_source
    from {{ ref('stg_health__bjaz_hat_id_mem_detls') }}
    where member_no is not null
    )

union all

select parent_bk, member_reference_ck, active_indicator, date_of_joining, designation_band, employee_id, location_reference, member_name, record_source from (
    select distinct
        part_id as parent_bk,
        cast(null as varchar) as member_reference_ck,
        nullif(trim(to_varchar(status)), '') as active_indicator,
        cast(null as varchar) as date_of_joining,
        cast(null as varchar) as designation_band,
        cast(null as varchar) as employee_id,
        cast(null as varchar) as location_reference,
        cast(null as varchar) as member_name,
        'BJAZ_HC_PART_EXTN' as record_source
    from {{ ref('stg_health__bjaz_hc_part_extn') }}
    where part_id is not null
    )

union all

select parent_bk, member_reference_ck, active_indicator, date_of_joining, designation_band, employee_id, location_reference, member_name, record_source from (
    select distinct
        ldr_pid as parent_bk,
        cast(null as varchar) as member_reference_ck,
        cast(null as varchar) as active_indicator,
        cast(null as varchar) as date_of_joining,
        cast(null as varchar) as designation_band,
        nullif(trim(to_varchar(emp_no)), '') as employee_id,
        cast(null as varchar) as location_reference,
        cast(null as varchar) as member_name,
        'BJAZ_HM_COINSU_CLM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_coinsu_clm_dtls') }}
    where ldr_pid is not null
    )

union all

select parent_bk, member_reference_ck, active_indicator, date_of_joining, designation_band, employee_id, location_reference, member_name, record_source from (
    select distinct
        hospital_id as parent_bk,
        cast(null as varchar) as member_reference_ck,
        cast(null as varchar) as active_indicator,
        nullif(trim(to_varchar(doj)), '') as date_of_joining,
        cast(null as varchar) as designation_band,
        cast(null as varchar) as employee_id,
        cast(null as varchar) as location_reference,
        cast(null as varchar) as member_name,
        'BJAZ_HM_HCM_EXTRACT' as record_source
    from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
    where hospital_id is not null
    )

union all

select parent_bk, member_reference_ck, active_indicator, date_of_joining, designation_band, employee_id, location_reference, member_name, record_source from (
    select distinct
        member_id as parent_bk,
        cast(null as varchar) as member_reference_ck,
        cast(null as varchar) as active_indicator,
        cast(null as varchar) as date_of_joining,
        nullif(trim(to_varchar(grade)), '') as designation_band,
        nullif(trim(to_varchar(hat_empcode)), '') as employee_id,
        nullif(trim(to_varchar(employee_location)), '') as location_reference,
        cast(null as varchar) as member_name,
        'BJAZ_HM_MEMBER_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_member_dtls') }}
    where member_id is not null
    )

union all

select parent_bk, member_reference_ck, active_indicator, date_of_joining, designation_band, employee_id, location_reference, member_name, record_source from (
    select distinct
        payer_code as parent_bk,
        cast(null as varchar) as member_reference_ck,
        cast(null as varchar) as active_indicator,
        cast(null as varchar) as date_of_joining,
        cast(null as varchar) as designation_band,
        nullif(trim(to_varchar(employee_id)), '') as employee_id,
        cast(null as varchar) as location_reference,
        cast(null as varchar) as member_name,
        'BJAZ_REMEDINET_CLAIM_DETAILS' as record_source
    from {{ ref('stg_health__bjaz_remedinet_claim_details') }}
    where payer_code is not null
    )

)
