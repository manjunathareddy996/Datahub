{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL stitch view for SAT_COMMON_ADDRESS (HUB_LOCATION grain).
-- 6 table(s) contributing at this grain, same join_helpers logic used for Health.
-- Reads raw Partner staging directly (stg_partner__*) -- no hashing here.
-- PLUS a composite_branch (mapper note, ADDRESS_KEY_FIX_PARTNER.md / round-4 feedback):
-- 5 more tables with address text but no location-id column, previously entirely unbuilt.
-- Key = content hash of the full normalized address (order: Building/Door, Street,
-- Locality, City, District, State, Postal Code, Country -- upper/trim, drop nulls; degenerates
-- to a single column where only one address part exists, e.g. BJAZ_SH_MEM_DTLS_EXTN). Dedup
-- by content -- NOT pincode alone, since SAT_COMMON_ADDRESS is single-active and a pincode
-- covers many distinct addresses. BJAZ_CTNGY_PA_MEM_DTLS contributes two separate branches
-- (member's address, with finer-grained parts, and the assignee's -- a different subject,
-- only a single free-text line, not fabricated by borrowing the member's city/state/pin).

with code_branch as (
select parent_bk, addressline1, addressline2, addressline3, buildingname, city, countrycode, countryname, doornumber, postalcode, statename, streetname, record_source
from (
    with t0 as (
        select distinct
            add_id as parent_bk,
            nullif(trim(to_varchar(address_line6)), '') as addressline2,
            nullif(trim(to_varchar(address_line7)), '') as addressline3,
            nullif(trim(to_varchar(building_name)), '') as buildingname,
            nullif(trim(to_varchar(residence_country)), '') as countryname,
            nullif(trim(to_varchar(door_no)), '') as doornumber,
            nullif(trim(to_varchar(plot_street_no)), '') as streetname
        from {{ ref('stg_partner__azbj_address_extn') }}
        where add_id is not null
        qualify row_number() over (partition by parent_bk order by addressline2, addressline3, buildingname, countryname, doornumber, streetname) = 1
    ),
         t1 as (
        select distinct
            billing_loc as parent_bk,
            nullif(trim(to_varchar(parent_co_add_line1)), '') as addressline1,
            nullif(trim(to_varchar(parent_co_add_line2)), '') as addressline2,
            nullif(trim(to_varchar(parent_co_add_line3)), '') as addressline3,
            nullif(trim(to_varchar(country_code)), '') as countrycode,
            nullif(trim(to_varchar(country)), '') as countryname,
            nullif(trim(to_varchar(billing_state)), '') as statename
        from {{ ref('stg_partner__bjaz_clm_supp_extn') }}
        where billing_loc is not null
        qualify row_number() over (partition by parent_bk order by addressline1, addressline2, addressline3, countrycode, countryname, statename) = 1
    ),
         t2 as (
        select distinct
            add_id as parent_bk,
            nullif(trim(to_varchar(address_line1)), '') as addressline1,
            nullif(trim(to_varchar(address_line2)), '') as addressline2,
            nullif(trim(to_varchar(address_line3)), '') as addressline3,
            nullif(trim(to_varchar(country_code)), '') as countrycode,
            nullif(trim(to_varchar(postcode)), '') as postalcode
        from {{ ref('stg_partner__bjaz_cp_add_hist') }}
        where add_id is not null
        qualify row_number() over (partition by parent_bk order by addressline1, addressline2, addressline3, countrycode, postalcode) = 1
    ),
         t3 as (
        select distinct
            pincode as parent_bk,
            nullif(trim(to_varchar(city)), '') as city,
            nullif(trim(to_varchar(status)), '') as postalcode,
            nullif(trim(to_varchar(state)), '') as statename
        from {{ ref('stg_partner__bjaz_pincode') }}
        where pincode is not null
        qualify row_number() over (partition by parent_bk order by city, postalcode, statename) = 1
    ),
         t4 as (
        select distinct
            pincode as parent_bk,
            nullif(trim(to_varchar(city)), '') as city,
            nullif(trim(to_varchar(state)), '') as statename
        from {{ ref('stg_partner__bjaz_pincode_master') }}
        where pincode is not null
        qualify row_number() over (partition by parent_bk order by city, statename) = 1
    ),
         t5 as (
        select distinct
            add_id as parent_bk,
            nullif(trim(to_varchar(address_line1)), '') as addressline1,
            nullif(trim(to_varchar(address_line2)), '') as addressline2,
            nullif(trim(to_varchar(address_line3)), '') as addressline3,
            nullif(trim(to_varchar(country_code)), '') as countrycode,
            nullif(trim(to_varchar(postcode)), '') as postalcode
        from {{ ref('stg_partner__cp_addresses') }}
        where add_id is not null
        qualify row_number() over (partition by parent_bk order by addressline1, addressline2, addressline3, countrycode, postalcode) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk, t4.parent_bk, t5.parent_bk) as parent_bk,
        coalesce(t1.addressline1, t2.addressline1, t5.addressline1) as addressline1,
        coalesce(t0.addressline2, t1.addressline2, t2.addressline2, t5.addressline2) as addressline2,
        coalesce(t0.addressline3, t1.addressline3, t2.addressline3, t5.addressline3) as addressline3,
        t0.buildingname as buildingname,
        coalesce(t3.city, t4.city) as city,
        coalesce(t1.countrycode, t2.countrycode, t5.countrycode) as countrycode,
        coalesce(t0.countryname, t1.countryname) as countryname,
        t0.doornumber as doornumber,
        coalesce(t2.postalcode, t3.postalcode, t5.postalcode) as postalcode,
        coalesce(t1.statename, t3.statename, t4.statename) as statename,
        t0.streetname as streetname,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'AZBJ_ADDRESS_EXTN' end, case when t1.parent_bk is not null then 'BJAZ_CLM_SUPP_EXTN' end, case when t2.parent_bk is not null then 'BJAZ_CP_ADD_HIST' end, case when t3.parent_bk is not null then 'BJAZ_PINCODE' end, case when t4.parent_bk is not null then 'BJAZ_PINCODE_MASTER' end, case when t5.parent_bk is not null then 'CP_ADDRESSES' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk
    full outer join t3 on coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk) = t3.parent_bk
    full outer join t4 on coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk) = t4.parent_bk
    full outer join t5 on coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk) = t5.parent_bk
    )
),

composite_branch as (
    select
    coalesce(nullif(upper(trim(to_varchar(address))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(city))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(state))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(pin))), ''), '') as parent_bk,
    nullif(upper(trim(to_varchar(address))), '') as addressline1,
    cast(null as varchar) as addressline2,
    cast(null as varchar) as addressline3,
    cast(null as varchar) as buildingname,
    nullif(upper(trim(to_varchar(city))), '') as city,
    cast(null as varchar) as countrycode,
    cast(null as varchar) as countryname,
    cast(null as varchar) as doornumber,
    nullif(upper(trim(to_varchar(pin))), '') as postalcode,
    nullif(upper(trim(to_varchar(state))), '') as statename,
    cast(null as varchar) as streetname,
    'BJAZ_HM_MEMBER_DTLS' as record_source
    from {{ ref('stg_partner__bjaz_hm_member_dtls') }}
    where nullif(upper(trim(to_varchar(address))), '') is not null or nullif(upper(trim(to_varchar(city))), '') is not null or nullif(upper(trim(to_varchar(state))), '') is not null or nullif(upper(trim(to_varchar(pin))), '') is not null

    union all

    select
    coalesce(nullif(upper(trim(to_varchar(address))), ''), '') as parent_bk,
    nullif(upper(trim(to_varchar(address))), '') as addressline1,
    cast(null as varchar) as addressline2,
    cast(null as varchar) as addressline3,
    cast(null as varchar) as buildingname,
    cast(null as varchar) as city,
    cast(null as varchar) as countrycode,
    cast(null as varchar) as countryname,
    cast(null as varchar) as doornumber,
    cast(null as varchar) as postalcode,
    cast(null as varchar) as statename,
    cast(null as varchar) as streetname,
    'BJAZ_SH_MEM_DTLS_EXTN' as record_source
    from {{ ref('stg_partner__bjaz_sh_mem_dtls_extn') }}
    where nullif(upper(trim(to_varchar(address))), '') is not null

    union all

    select
    coalesce(nullif(upper(trim(to_varchar(insured_address))), ''), '') as parent_bk,
    nullif(upper(trim(to_varchar(insured_address))), '') as addressline1,
    cast(null as varchar) as addressline2,
    cast(null as varchar) as addressline3,
    cast(null as varchar) as buildingname,
    cast(null as varchar) as city,
    cast(null as varchar) as countrycode,
    cast(null as varchar) as countryname,
    cast(null as varchar) as doornumber,
    cast(null as varchar) as postalcode,
    cast(null as varchar) as statename,
    cast(null as varchar) as streetname,
    'BJAZ_CTNGY_GC_MEM_DATA' as record_source
    from {{ ref('stg_partner__bjaz_ctngy_gc_mem_data') }}
    where nullif(upper(trim(to_varchar(insured_address))), '') is not null

    union all

    select
    coalesce(nullif(upper(trim(to_varchar(address1))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(address2))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(city_name))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(state_name))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(pin_code))), ''), '') as parent_bk,
    nullif(upper(trim(to_varchar(address1))), '') as addressline1,
    nullif(upper(trim(to_varchar(address2))), '') as addressline2,
    cast(null as varchar) as addressline3,
    cast(null as varchar) as buildingname,
    nullif(upper(trim(to_varchar(city_name))), '') as city,
    cast(null as varchar) as countrycode,
    cast(null as varchar) as countryname,
    cast(null as varchar) as doornumber,
    nullif(upper(trim(to_varchar(pin_code))), '') as postalcode,
    nullif(upper(trim(to_varchar(state_name))), '') as statename,
    cast(null as varchar) as streetname,
    'BJAZ_HM_HOSPITAL_MASTER' as record_source
    from {{ ref('stg_partner__bjaz_hm_hospital_master') }}
    where nullif(upper(trim(to_varchar(address1))), '') is not null or nullif(upper(trim(to_varchar(address2))), '') is not null or nullif(upper(trim(to_varchar(city_name))), '') is not null or nullif(upper(trim(to_varchar(state_name))), '') is not null or nullif(upper(trim(to_varchar(pin_code))), '') is not null

    union all

    select
    coalesce(nullif(upper(trim(to_varchar(house_no))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(street_name))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(mem_address))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(city))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(state))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(pin_code))), ''), '') as parent_bk,
    nullif(upper(trim(to_varchar(mem_address))), '') as addressline1,
    cast(null as varchar) as addressline2,
    cast(null as varchar) as addressline3,
    cast(null as varchar) as buildingname,
    nullif(upper(trim(to_varchar(city))), '') as city,
    cast(null as varchar) as countrycode,
    cast(null as varchar) as countryname,
    nullif(upper(trim(to_varchar(house_no))), '') as doornumber,
    nullif(upper(trim(to_varchar(pin_code))), '') as postalcode,
    nullif(upper(trim(to_varchar(state))), '') as statename,
    nullif(upper(trim(to_varchar(street_name))), '') as streetname,
    'BJAZ_CTNGY_PA_MEM_DTLS' as record_source
    from {{ ref('stg_partner__bjaz_ctngy_pa_mem_dtls') }}
    where nullif(upper(trim(to_varchar(house_no))), '') is not null or nullif(upper(trim(to_varchar(street_name))), '') is not null or nullif(upper(trim(to_varchar(mem_address))), '') is not null or nullif(upper(trim(to_varchar(city))), '') is not null or nullif(upper(trim(to_varchar(state))), '') is not null or nullif(upper(trim(to_varchar(pin_code))), '') is not null

    union all

    select
    coalesce(nullif(upper(trim(to_varchar(assigne_address))), ''), '') as parent_bk,
    nullif(upper(trim(to_varchar(assigne_address))), '') as addressline1,
    cast(null as varchar) as addressline2,
    cast(null as varchar) as addressline3,
    cast(null as varchar) as buildingname,
    cast(null as varchar) as city,
    cast(null as varchar) as countrycode,
    cast(null as varchar) as countryname,
    cast(null as varchar) as doornumber,
    cast(null as varchar) as postalcode,
    cast(null as varchar) as statename,
    cast(null as varchar) as streetname,
    'BJAZ_CTNGY_PA_MEM_DTLS' as record_source
    from {{ ref('stg_partner__bjaz_ctngy_pa_mem_dtls') }}
    where nullif(upper(trim(to_varchar(assigne_address))), '') is not null
)

select * from code_branch
union all
select * from composite_branch
