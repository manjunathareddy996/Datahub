-- Intermediate harmonisation view for SAT_PROVIDER_TARIFF (HUB_PARTY grain).
-- Stitched via a single source table, plus a UNION-appended fallback for 2 table(s) that lack the full multi-active child key.
-- record_source lists every table that actually contributed to a given row.
select * from (

select parent_bk, service_code_ck, discount_percentage, effective_date, expiry_date, package_rate, room_rent_cap, service_description, record_source from (
    select distinct
        hosid as parent_bk,
        cast(null as varchar) as service_code_ck,
        nullif(trim(to_varchar(pp_discount1)), '') as discount_percentage,
        nullif(trim(to_varchar(tariff_from_date)), '') as effective_date,
        nullif(trim(to_varchar(tariff_to_date)), '') as expiry_date,
        nullif(trim(to_varchar(package_rates)), '') as package_rate,
        cast(null as varchar) as room_rent_cap,
        nullif(trim(to_varchar(pp_disc_services1)), '') as service_description,
        'BJAZ_HM_HOSPITAL_MASTER_EXTN' as record_source
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where hosid is not null
    )

union all

select parent_bk, service_code_ck, discount_percentage, effective_date, expiry_date, package_rate, room_rent_cap, service_description, record_source from (
    select distinct
        hosid as parent_bk,
        cast(null as varchar) as service_code_ck,
        cast(null as varchar) as discount_percentage,
        cast(null as varchar) as effective_date,
        cast(null as varchar) as expiry_date,
        cast(null as varchar) as package_rate,
        nullif(trim(to_varchar(stepdwnrmrent)), '') as room_rent_cap,
        cast(null as varchar) as service_description,
        'BJAZ_HM_HOSP_MASTER_EXTN1' as record_source
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where hosid is not null
    )

)
