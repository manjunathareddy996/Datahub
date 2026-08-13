-- Intermediate harmonisation view for SAT_COMMON_ADDRESS (HUB_LOCATION grain).
-- Stitched via a FULL OUTER JOIN + COALESCE chain across 6 table(s).
-- record_source lists every table that actually contributed to a given row.
select parent_bk, address_line_1, address_line_2, building_name, city, country_code, country_name, landmark, locality, post_office_name, postal_code, state_name, street_name, village, record_source
from (
    with t0 as (
        select distinct
            risk_location as parent_bk,
            nullif(trim(to_varchar(address_line1)), '') as address_line_1,
            nullif(trim(to_varchar(address_line2)), '') as address_line_2,
            nullif(trim(to_varchar(city)), '') as city,
            nullif(trim(to_varchar(area)), '') as locality,
            nullif(trim(to_varchar(postcode)), '') as postal_code,
            nullif(trim(to_varchar(state)), '') as state_name
        from {{ ref('stg_health__bjaz_ehh_pol_dtls') }}
        where risk_location is not null
        qualify row_number() over (partition by parent_bk order by address_line_1, address_line_2, city, locality, postal_code, state_name) = 1
    ),
         t1 as (
        select distinct
            locationcode as parent_bk,
            nullif(trim(to_varchar(building)), '') as building_name,
            nullif(trim(to_varchar(city)), '') as city,
            nullif(trim(to_varchar(country)), '') as country_name,
            nullif(trim(to_varchar(pincode)), '') as postal_code,
            nullif(trim(to_varchar(state)), '') as state_name,
            nullif(trim(to_varchar(streetname)), '') as street_name
        from {{ ref('stg_health__bjaz_generic_loader_log_table') }}
        where locationcode is not null
        qualify row_number() over (partition by parent_bk order by building_name, city, country_name, postal_code, state_name, street_name) = 1
    ),
         t2 as (
        select distinct
            policy_location as parent_bk,
            nullif(trim(to_varchar(patient_address)), '') as address_line_1
        from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
        where policy_location is not null
        qualify row_number() over (partition by parent_bk order by address_line_1) = 1
    ),
         t3 as (
        select distinct
            pin_code as parent_bk,
            nullif(trim(to_varchar(address1)), '') as address_line_1,
            nullif(trim(to_varchar(address2)), '') as address_line_2,
            nullif(trim(to_varchar(city_name)), '') as city,
            nullif(trim(to_varchar(pin_code)), '') as postal_code,
            nullif(trim(to_varchar(state_name)), '') as state_name
        from {{ ref('stg_health__bjaz_hm_hospital_master') }}
        where pin_code is not null
        qualify row_number() over (partition by parent_bk order by address_line_1, address_line_2, city, postal_code, state_name) = 1
    ),
         t4 as (
        select distinct
            location_code as parent_bk,
            nullif(trim(to_varchar(city_name)), '') as city,
            nullif(trim(to_varchar(pin_code)), '') as postal_code,
            nullif(trim(to_varchar(state_name)), '') as state_name
        from {{ ref('stg_health__bjaz_hm_inward_dtls') }}
        where location_code is not null
        qualify row_number() over (partition by parent_bk order by city, postal_code, state_name) = 1
    ),
         t5 as (
        select distinct
            orphan_loc as parent_bk,
            nullif(trim(to_varchar(address)), '') as address_line_1
        from {{ ref('stg_health__bjaz_hm_orphan_reg') }}
        where orphan_loc is not null
        qualify row_number() over (partition by parent_bk order by address_line_1) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk, t4.parent_bk, t5.parent_bk) as parent_bk,
        coalesce(t0.address_line_1, t2.address_line_1, t3.address_line_1, t5.address_line_1) as address_line_1,
        coalesce(t0.address_line_2, t3.address_line_2) as address_line_2,
        coalesce(t1.building_name) as building_name,
        coalesce(t0.city, t1.city, t3.city, t4.city) as city,
        cast(null as varchar) as country_code,
        coalesce(t1.country_name) as country_name,
        cast(null as varchar) as landmark,
        coalesce(t0.locality) as locality,
        cast(null as varchar) as post_office_name,
        coalesce(t0.postal_code, t1.postal_code, t3.postal_code, t4.postal_code) as postal_code,
        coalesce(t0.state_name, t1.state_name, t3.state_name, t4.state_name) as state_name,
        coalesce(t1.street_name) as street_name,
        cast(null as varchar) as village,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BJAZ_EHH_POL_DTLS' end, case when t1.parent_bk is not null then 'BJAZ_GENERIC_LOADER_LOG_TABLE' end, case when t2.parent_bk is not null then 'BJAZ_HM_HCM_EXTRACT' end, case when t3.parent_bk is not null then 'BJAZ_HM_HOSPITAL_MASTER' end, case when t4.parent_bk is not null then 'BJAZ_HM_INWARD_DTLS' end, case when t5.parent_bk is not null then 'BJAZ_HM_ORPHAN_REG' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk
    full outer join t3 on coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk) = t3.parent_bk
    full outer join t4 on coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk) = t4.parent_bk
    full outer join t5 on coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk) = t5.parent_bk
    )
