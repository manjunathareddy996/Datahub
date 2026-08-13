-- Intermediate harmonisation view for SAT_PARTY_PROVIDER_CAPABILITY (HUB_PARTY grain).
-- Stitched via a single source table, plus a UNION-appended fallback for 4 table(s) that lack the full multi-active child key.
-- record_source lists every table that actually contributed to a given row.
select * from (

select parent_bk, facility_code_ck, accreditation_indicator, accreditation_reference, available_indicator, capability_remarks, capacity, facility_category, facility_count, facility_name, record_source from (
    select distinct
        part_id as parent_bk,
        cast(null as varchar) as facility_code_ck,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        cast(null as varchar) as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        cast(null as varchar) as facility_category,
        cast(null as varchar) as facility_count,
        nullif(trim(to_varchar(hospital_detail)), '') as facility_name,
        'BJAZ_HC_PART_EXTN' as record_source
    from {{ ref('stg_health__bjaz_hc_part_extn') }}
    where part_id is not null
    )

union all

select parent_bk, facility_code_ck, accreditation_indicator, accreditation_reference, available_indicator, capability_remarks, capacity, facility_category, facility_count, facility_name, record_source from (
    select distinct
        hosid as parent_bk,
        cast(null as varchar) as facility_code_ck,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        nullif(trim(to_varchar(diagno_yn)), '') as available_indicator,
        cast(null as varchar) as capability_remarks,
        cast(null as varchar) as capacity,
        nullif(trim(to_varchar(hosp_spec_type)), '') as facility_category,
        cast(null as varchar) as facility_count,
        nullif(trim(to_varchar(hosp_speciality)), '') as facility_name,
        'BJAZ_HM_HOSPITAL_MASTER' as record_source
    from {{ ref('stg_health__bjaz_hm_hospital_master') }}
    where hosid is not null
    )

union all

select parent_bk, facility_code_ck, accreditation_indicator, accreditation_reference, available_indicator, capability_remarks, capacity, facility_category, facility_count, facility_name, record_source from (
    select distinct
        hosid as parent_bk,
        cast(null as varchar) as facility_code_ck,
        cast(null as varchar) as accreditation_indicator,
        cast(null as varchar) as accreditation_reference,
        nullif(trim(to_varchar(cr_card_accepted)), '') as available_indicator,
        cast(null as varchar) as capability_remarks,
        nullif(trim(to_varchar(total_beds)), '') as capacity,
        cast(null as varchar) as facility_category,
        nullif(trim(to_varchar(no_oprn_theatres)), '') as facility_count,
        cast(null as varchar) as facility_name,
        'BJAZ_HM_HOSPITAL_MASTER_EXTN' as record_source
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where hosid is not null
    )

union all

select parent_bk, facility_code_ck, accreditation_indicator, accreditation_reference, available_indicator, capability_remarks, capacity, facility_category, facility_count, facility_name, record_source from (
    select distinct
        hosid as parent_bk,
        cast(null as varchar) as facility_code_ck,
        nullif(trim(to_varchar(nabhcertified)), '') as accreditation_indicator,
        nullif(trim(to_varchar(stat_lvl_nqas)), '') as accreditation_reference,
        nullif(trim(to_varchar(opthamology)), '') as available_indicator,
        nullif(trim(to_varchar(operatinghrs)), '') as capability_remarks,
        nullif(trim(to_varchar(semitwin)), '') as capacity,
        cast(null as varchar) as facility_category,
        nullif(trim(to_varchar(tot_no_doct)), '') as facility_count,
        cast(null as varchar) as facility_name,
        'BJAZ_HM_HOSP_MASTER_EXTN1' as record_source
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where hosid is not null
    )

)
