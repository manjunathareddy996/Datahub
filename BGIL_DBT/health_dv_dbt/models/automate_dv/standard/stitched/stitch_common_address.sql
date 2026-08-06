{{ config(materialized='view') }}

-- STANDARD-MODEL stitch view for SAT_COMMON_ADDRESS (HUB_LOCATION grain).
-- Attribute-level merge across 5 code-keyed table(s) sharing this grain: FULL OUTER JOIN + COALESCE.
-- Reads raw production staging directly (stg_health__*) -- NOT a per-table stage() output; there is
-- nothing to hash until this join has produced one clean row per key. Hashing happens exactly once,
-- downstream, in the companion stg2_common_address.sql stage() model.
--
-- PLUS a composite_branch (data_5a.js M4): 4 tables, UNION'd in (not joined -- these are
-- union-only contributors, so reading their own per-table stage() output directly is fine per
-- the routing rule). LOCATION_CODE_KEY is their synthetic composite-address key (no real
-- location code on these tables) -- see stg2_addrusage_*.sql. These are the tables that used
-- to feed the now-removed SAT_PARTY_ADDRESS_USAGE; the address text now lives here instead.
--
-- PLUS a rekey_branch (round 4, ADDRESS_KEY_FIX_HEALTH.md / Health_address_rekey.csv, closed
-- per MAPPER_REPLY_ADDRESS_REKEY_HEALTH.md): BJAZ_HM_HOSPITAL_MASTER was REMOVED from the
-- code_branch FULL OUTER JOIN chain below (it used to be t3, keyed bare on pin_code) and
-- rebuilt here instead, keyed on the content hash of its full address -- the exact same bug
-- shape as Travel's TRANSITFROM catch: SAT_COMMON_ADDRESS is single-active, so a bare pincode
-- key collapses every distinct address in that pincode onto one row. 14 more tables (previously
-- unbuilt for address purposes -- the mapping left HUB_LOCATION's key_name null on all of them)
-- join this same branch, all keyed the same way: content hash of whatever address parts each
-- table actually has (order: Building/Door, Street, Locality, City, District, State, Postal
-- Code, Country -- upper/trim, drop nulls; degenerates to a single/two-column key where fewer
-- parts exist, e.g. BJAZ_HM_HOSP_MASTER_EXTN1 on AREA alone, or BJAZ_HM_COINSU_CLM_DTLS on the
-- coarse NETWORK_CITY|STATE pair -- no street/pincode on that table). Two tables (BJAZ_HG_POL_
-- DTLS, BJAZ_TPA_CLAIM_DETAILS_WS) each contribute more than one branch -- they carry more than
-- one genuinely distinct address on the same row (current vs. dispatch/mailing; customer/
-- insured vs. hospital) and are not conflated into one key. This closes all 17 tables in the
-- mapper's list (15 here + the 2 already-existing M4 tables rekeyed above).

with code_branch as (
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
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk, t4.parent_bk, t5.parent_bk) as parent_bk,
        coalesce(t0.address_line_1, t2.address_line_1, t5.address_line_1) as address_line_1,
        coalesce(t0.address_line_2) as address_line_2,
        coalesce(t1.building_name) as building_name,
        coalesce(t0.city, t1.city, t4.city) as city,
        cast(null as varchar) as country_code,
        coalesce(t1.country_name) as country_name,
        cast(null as varchar) as landmark,
        coalesce(t0.locality) as locality,
        cast(null as varchar) as post_office_name,
        coalesce(t0.postal_code, t1.postal_code, t4.postal_code) as postal_code,
        coalesce(t0.state_name, t1.state_name, t4.state_name) as state_name,
        coalesce(t1.street_name) as street_name,
        cast(null as varchar) as village,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BJAZ_EHH_POL_DTLS' end, case when t1.parent_bk is not null then 'BJAZ_GENERIC_LOADER_LOG_TABLE' end, case when t2.parent_bk is not null then 'BJAZ_HM_HCM_EXTRACT' end, case when t4.parent_bk is not null then 'BJAZ_HM_INWARD_DTLS' end, case when t5.parent_bk is not null then 'BJAZ_HM_ORPHAN_REG' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk
    full outer join t4 on coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk) = t4.parent_bk
    full outer join t5 on coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t4.parent_bk) = t5.parent_bk
    )
),

composite_branch as (
    select
        location_code_key as parent_bk,
        address_line_1, address_line_2,
        cast(null as varchar) as building_name,
        city,
        cast(null as varchar) as country_code,
        cast(null as varchar) as country_name,
        cast(null as varchar) as landmark,
        cast(null as varchar) as locality,
        cast(null as varchar) as post_office_name,
        postal_code,
        state_code as state_name,
        cast(null as varchar) as street_name,
        cast(null as varchar) as village,
        record_source
    from {{ ref('stg2_addrusage_ba_hcp_pp_mem_dtls') }}
    where location_code_key is not null

    union all

    select
        location_code_key as parent_bk,
        address_line_1, address_line_2,
        cast(null as varchar) as building_name,
        city,
        cast(null as varchar) as country_code,
        cast(null as varchar) as country_name,
        cast(null as varchar) as landmark,
        cast(null as varchar) as locality,
        cast(null as varchar) as post_office_name,
        postal_code,
        state_code as state_name,
        cast(null as varchar) as street_name,
        cast(null as varchar) as village,
        record_source
    from {{ ref('stg2_addrusage_bjaz_bandhan_medi_clam') }}
    where location_code_key is not null

    union all

    select
        location_code_key as parent_bk,
        address_line_1, address_line_2,
        cast(null as varchar) as building_name,
        city,
        cast(null as varchar) as country_code,
        cast(null as varchar) as country_name,
        cast(null as varchar) as landmark,
        cast(null as varchar) as locality,
        cast(null as varchar) as post_office_name,
        postal_code,
        state_code as state_name,
        cast(null as varchar) as street_name,
        cast(null as varchar) as village,
        record_source
    from {{ ref('stg2_addrusage_bjaz_tpa_claim_details_ws') }}
    where location_code_key is not null

    union all

    select
        location_code_key as parent_bk,
        address_line_1, address_line_2,
        cast(null as varchar) as building_name,
        city,
        cast(null as varchar) as country_code,
        cast(null as varchar) as country_name,
        cast(null as varchar) as landmark,
        cast(null as varchar) as locality,
        cast(null as varchar) as post_office_name,
        postal_code,
        state_code as state_name,
        cast(null as varchar) as street_name,
        cast(null as varchar) as village,
        record_source
    from {{ ref('stg2_addrusage_bjaz_hat_id_mem_detls') }}
    where location_code_key is not null
),

rekey_branch as (
    select
        coalesce(nullif(upper(trim(to_varchar(pd_address_line_1))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(pd_address_line_2))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(pd_area_as_per_pf))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(pd_area_post_office))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(pd_city))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(pd_state))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(pd_pin_code))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(pd_country))), ''), '') as parent_bk,
        nullif(upper(trim(to_varchar(pd_address_line_1))), '') as address_line_1,
        nullif(upper(trim(to_varchar(pd_address_line_2))), '') as address_line_2,
        cast(null as varchar) as building_name,
        nullif(upper(trim(to_varchar(pd_city))), '') as city,
        cast(null as varchar) as country_code,
        nullif(upper(trim(to_varchar(pd_country))), '') as country_name,
        cast(null as varchar) as landmark,
        nullif(upper(trim(to_varchar(pd_area_as_per_pf))), '') as locality,
        nullif(upper(trim(to_varchar(pd_area_post_office))), '') as post_office_name,
        nullif(upper(trim(to_varchar(pd_pin_code))), '') as postal_code,
        nullif(upper(trim(to_varchar(pd_state))), '') as state_name,
        cast(null as varchar) as street_name,
        cast(null as varchar) as village,
        'BA_HCP_PROD_8439_CLH_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
    where nullif(upper(trim(to_varchar(pd_address_line_1))), '') is not null or nullif(upper(trim(to_varchar(pd_address_line_2))), '') is not null or nullif(upper(trim(to_varchar(pd_area_as_per_pf))), '') is not null or nullif(upper(trim(to_varchar(pd_area_post_office))), '') is not null or nullif(upper(trim(to_varchar(pd_city))), '') is not null or nullif(upper(trim(to_varchar(pd_state))), '') is not null or nullif(upper(trim(to_varchar(pd_pin_code))), '') is not null or nullif(upper(trim(to_varchar(pd_country))), '') is not null

    union all

    select
        coalesce(nullif(upper(trim(to_varchar(pd_address_line_1))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(pd_address_line_2))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(pd_area_as_per_pf))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(pd_area_post_office))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(pd_city))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(pd_state))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(pd_pin_code))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(pd_country))), ''), '') as parent_bk,
        nullif(upper(trim(to_varchar(pd_address_line_1))), '') as address_line_1,
        nullif(upper(trim(to_varchar(pd_address_line_2))), '') as address_line_2,
        cast(null as varchar) as building_name,
        nullif(upper(trim(to_varchar(pd_city))), '') as city,
        cast(null as varchar) as country_code,
        nullif(upper(trim(to_varchar(pd_country))), '') as country_name,
        cast(null as varchar) as landmark,
        nullif(upper(trim(to_varchar(pd_area_as_per_pf))), '') as locality,
        nullif(upper(trim(to_varchar(pd_area_post_office))), '') as post_office_name,
        nullif(upper(trim(to_varchar(pd_pin_code))), '') as postal_code,
        nullif(upper(trim(to_varchar(pd_state))), '') as state_name,
        cast(null as varchar) as street_name,
        cast(null as varchar) as village,
        'BA_HCP_PROD_8432_ECP_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
    where nullif(upper(trim(to_varchar(pd_address_line_1))), '') is not null or nullif(upper(trim(to_varchar(pd_address_line_2))), '') is not null or nullif(upper(trim(to_varchar(pd_area_as_per_pf))), '') is not null or nullif(upper(trim(to_varchar(pd_area_post_office))), '') is not null or nullif(upper(trim(to_varchar(pd_city))), '') is not null or nullif(upper(trim(to_varchar(pd_state))), '') is not null or nullif(upper(trim(to_varchar(pd_pin_code))), '') is not null or nullif(upper(trim(to_varchar(pd_country))), '') is not null

    union all

    select
        coalesce(nullif(upper(trim(to_varchar(pd_address_line_1))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(pd_address_line_2))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(pd_area_as_per_pf))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(pd_area_post_office))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(pd_city))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(pd_state))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(pd_pin_code))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(pd_country))), ''), '') as parent_bk,
        nullif(upper(trim(to_varchar(pd_address_line_1))), '') as address_line_1,
        nullif(upper(trim(to_varchar(pd_address_line_2))), '') as address_line_2,
        cast(null as varchar) as building_name,
        nullif(upper(trim(to_varchar(pd_city))), '') as city,
        cast(null as varchar) as country_code,
        nullif(upper(trim(to_varchar(pd_country))), '') as country_name,
        cast(null as varchar) as landmark,
        nullif(upper(trim(to_varchar(pd_area_as_per_pf))), '') as locality,
        nullif(upper(trim(to_varchar(pd_area_post_office))), '') as post_office_name,
        nullif(upper(trim(to_varchar(pd_pin_code))), '') as postal_code,
        nullif(upper(trim(to_varchar(pd_state))), '') as state_name,
        cast(null as varchar) as street_name,
        cast(null as varchar) as village,
        'BA_HCP_PROD_8433_FHC_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
    where nullif(upper(trim(to_varchar(pd_address_line_1))), '') is not null or nullif(upper(trim(to_varchar(pd_address_line_2))), '') is not null or nullif(upper(trim(to_varchar(pd_area_as_per_pf))), '') is not null or nullif(upper(trim(to_varchar(pd_area_post_office))), '') is not null or nullif(upper(trim(to_varchar(pd_city))), '') is not null or nullif(upper(trim(to_varchar(pd_state))), '') is not null or nullif(upper(trim(to_varchar(pd_pin_code))), '') is not null or nullif(upper(trim(to_varchar(pd_country))), '') is not null

    union all

    select
        coalesce(nullif(upper(trim(to_varchar(pd_address_line_1))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(pd_address_line_2))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(pd_area_as_per_pf))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(pd_area_post_office))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(pd_city))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(pd_state))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(pd_pin_code))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(pd_country))), ''), '') as parent_bk,
        nullif(upper(trim(to_varchar(pd_address_line_1))), '') as address_line_1,
        nullif(upper(trim(to_varchar(pd_address_line_2))), '') as address_line_2,
        cast(null as varchar) as building_name,
        nullif(upper(trim(to_varchar(pd_city))), '') as city,
        cast(null as varchar) as country_code,
        nullif(upper(trim(to_varchar(pd_country))), '') as country_name,
        cast(null as varchar) as landmark,
        nullif(upper(trim(to_varchar(pd_area_as_per_pf))), '') as locality,
        nullif(upper(trim(to_varchar(pd_area_post_office))), '') as post_office_name,
        nullif(upper(trim(to_varchar(pd_pin_code))), '') as postal_code,
        nullif(upper(trim(to_varchar(pd_state))), '') as state_name,
        cast(null as varchar) as street_name,
        cast(null as varchar) as village,
        'BA_HCP_PROD_8428_GPG_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
    where nullif(upper(trim(to_varchar(pd_address_line_1))), '') is not null or nullif(upper(trim(to_varchar(pd_address_line_2))), '') is not null or nullif(upper(trim(to_varchar(pd_area_as_per_pf))), '') is not null or nullif(upper(trim(to_varchar(pd_area_post_office))), '') is not null or nullif(upper(trim(to_varchar(pd_city))), '') is not null or nullif(upper(trim(to_varchar(pd_state))), '') is not null or nullif(upper(trim(to_varchar(pd_pin_code))), '') is not null or nullif(upper(trim(to_varchar(pd_country))), '') is not null

    union all

    select
        coalesce(nullif(upper(trim(to_varchar(mailing_pincode))), ''), '') as parent_bk,
        cast(null as varchar) as address_line_1,
        cast(null as varchar) as address_line_2,
        cast(null as varchar) as building_name,
        cast(null as varchar) as city,
        cast(null as varchar) as country_code,
        cast(null as varchar) as country_name,
        cast(null as varchar) as landmark,
        cast(null as varchar) as locality,
        cast(null as varchar) as post_office_name,
        nullif(upper(trim(to_varchar(mailing_pincode))), '') as postal_code,
        cast(null as varchar) as state_name,
        cast(null as varchar) as street_name,
        cast(null as varchar) as village,
        'BJAZ_GPG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
    where nullif(upper(trim(to_varchar(mailing_pincode))), '') is not null

    union all

    select
        coalesce(nullif(upper(trim(to_varchar(address_line_1))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(address_line_2))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(city))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(state))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(pin_code))), ''), '') as parent_bk,
        nullif(upper(trim(to_varchar(address_line_1))), '') as address_line_1,
        nullif(upper(trim(to_varchar(address_line_2))), '') as address_line_2,
        cast(null as varchar) as building_name,
        nullif(upper(trim(to_varchar(city))), '') as city,
        cast(null as varchar) as country_code,
        cast(null as varchar) as country_name,
        cast(null as varchar) as landmark,
        cast(null as varchar) as locality,
        cast(null as varchar) as post_office_name,
        nullif(upper(trim(to_varchar(pin_code))), '') as postal_code,
        nullif(upper(trim(to_varchar(state))), '') as state_name,
        cast(null as varchar) as street_name,
        cast(null as varchar) as village,
        'BJAZ_GRP_HLT_CUST_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_cust_dtls') }}
    where nullif(upper(trim(to_varchar(address_line_1))), '') is not null or nullif(upper(trim(to_varchar(address_line_2))), '') is not null or nullif(upper(trim(to_varchar(city))), '') is not null or nullif(upper(trim(to_varchar(state))), '') is not null or nullif(upper(trim(to_varchar(pin_code))), '') is not null

    union all

    select
        coalesce(nullif(upper(trim(to_varchar(landmark_1))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(country_name))), ''), '') as parent_bk,
        cast(null as varchar) as address_line_1,
        cast(null as varchar) as address_line_2,
        cast(null as varchar) as building_name,
        cast(null as varchar) as city,
        cast(null as varchar) as country_code,
        nullif(upper(trim(to_varchar(country_name))), '') as country_name,
        nullif(upper(trim(to_varchar(landmark_1))), '') as landmark,
        cast(null as varchar) as locality,
        cast(null as varchar) as post_office_name,
        cast(null as varchar) as postal_code,
        cast(null as varchar) as state_name,
        cast(null as varchar) as street_name,
        cast(null as varchar) as village,
        'BJAZ_HM_HOSPITAL_MASTER_EXTN' as record_source
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where nullif(upper(trim(to_varchar(landmark_1))), '') is not null or nullif(upper(trim(to_varchar(country_name))), '') is not null

    union all

    select
        coalesce(nullif(upper(trim(to_varchar(area))), ''), '') as parent_bk,
        cast(null as varchar) as address_line_1,
        cast(null as varchar) as address_line_2,
        cast(null as varchar) as building_name,
        cast(null as varchar) as city,
        cast(null as varchar) as country_code,
        cast(null as varchar) as country_name,
        cast(null as varchar) as landmark,
        nullif(upper(trim(to_varchar(area))), '') as locality,
        cast(null as varchar) as post_office_name,
        cast(null as varchar) as postal_code,
        cast(null as varchar) as state_name,
        cast(null as varchar) as street_name,
        cast(null as varchar) as village,
        'BJAZ_HM_HOSP_MASTER_EXTN1' as record_source
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where nullif(upper(trim(to_varchar(area))), '') is not null

    union all

    select
        coalesce(nullif(upper(trim(to_varchar(address))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(city))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(state))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(pin))), ''), '') as parent_bk,
        nullif(upper(trim(to_varchar(address))), '') as address_line_1,
        cast(null as varchar) as address_line_2,
        cast(null as varchar) as building_name,
        nullif(upper(trim(to_varchar(city))), '') as city,
        cast(null as varchar) as country_code,
        cast(null as varchar) as country_name,
        cast(null as varchar) as landmark,
        cast(null as varchar) as locality,
        cast(null as varchar) as post_office_name,
        nullif(upper(trim(to_varchar(pin))), '') as postal_code,
        nullif(upper(trim(to_varchar(state))), '') as state_name,
        cast(null as varchar) as street_name,
        cast(null as varchar) as village,
        'BJAZ_HM_MEMBER_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_member_dtls') }}
    where nullif(upper(trim(to_varchar(address))), '') is not null or nullif(upper(trim(to_varchar(city))), '') is not null or nullif(upper(trim(to_varchar(state))), '') is not null or nullif(upper(trim(to_varchar(pin))), '') is not null

    union all

    select
        coalesce(nullif(upper(trim(to_varchar(address))), ''), '') as parent_bk,
        nullif(upper(trim(to_varchar(address))), '') as address_line_1,
        cast(null as varchar) as address_line_2,
        cast(null as varchar) as building_name,
        cast(null as varchar) as city,
        cast(null as varchar) as country_code,
        cast(null as varchar) as country_name,
        cast(null as varchar) as landmark,
        cast(null as varchar) as locality,
        cast(null as varchar) as post_office_name,
        cast(null as varchar) as postal_code,
        cast(null as varchar) as state_name,
        cast(null as varchar) as street_name,
        cast(null as varchar) as village,
        'BJAZ_SH_MEM_DTLS_EXTN' as record_source
    from {{ ref('stg_health__bjaz_sh_mem_dtls_extn') }}
    where nullif(upper(trim(to_varchar(address))), '') is not null

    union all

    select
        coalesce(nullif(upper(trim(to_varchar(address_line1))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(address_line2))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(area))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(other_area))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(city))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(state))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(curr_pincode))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(country_code))), ''), '') as parent_bk,
        nullif(upper(trim(to_varchar(address_line1))), '') as address_line_1,
        nullif(upper(trim(to_varchar(address_line2))), '') as address_line_2,
        cast(null as varchar) as building_name,
        nullif(upper(trim(to_varchar(city))), '') as city,
        nullif(upper(trim(to_varchar(country_code))), '') as country_code,
        cast(null as varchar) as country_name,
        cast(null as varchar) as landmark,
        nullif(upper(trim(to_varchar(area))), '') as locality,
        cast(null as varchar) as post_office_name,
        nullif(upper(trim(to_varchar(curr_pincode))), '') as postal_code,
        nullif(upper(trim(to_varchar(state))), '') as state_name,
        cast(null as varchar) as street_name,
        nullif(upper(trim(to_varchar(other_area))), '') as village,
        'BJAZ_HG_POL_DTLS (current)' as record_source
    from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
    where nullif(upper(trim(to_varchar(address_line1))), '') is not null or nullif(upper(trim(to_varchar(address_line2))), '') is not null or nullif(upper(trim(to_varchar(area))), '') is not null or nullif(upper(trim(to_varchar(other_area))), '') is not null or nullif(upper(trim(to_varchar(city))), '') is not null or nullif(upper(trim(to_varchar(state))), '') is not null or nullif(upper(trim(to_varchar(curr_pincode))), '') is not null or nullif(upper(trim(to_varchar(country_code))), '') is not null

    union all

    select
        coalesce(nullif(upper(trim(to_varchar(disp_address_line1))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(disp_address_line2))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(disp_area))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(disp_other_area))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(disp_city))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(disp_state))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(mailing_pincode))), ''), '') as parent_bk,
        nullif(upper(trim(to_varchar(disp_address_line1))), '') as address_line_1,
        nullif(upper(trim(to_varchar(disp_address_line2))), '') as address_line_2,
        cast(null as varchar) as building_name,
        nullif(upper(trim(to_varchar(disp_city))), '') as city,
        cast(null as varchar) as country_code,
        cast(null as varchar) as country_name,
        cast(null as varchar) as landmark,
        nullif(upper(trim(to_varchar(disp_area))), '') as locality,
        cast(null as varchar) as post_office_name,
        nullif(upper(trim(to_varchar(mailing_pincode))), '') as postal_code,
        nullif(upper(trim(to_varchar(disp_state))), '') as state_name,
        cast(null as varchar) as street_name,
        nullif(upper(trim(to_varchar(disp_other_area))), '') as village,
        'BJAZ_HG_POL_DTLS (dispatch)' as record_source
    from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
    where nullif(upper(trim(to_varchar(disp_address_line1))), '') is not null or nullif(upper(trim(to_varchar(disp_address_line2))), '') is not null or nullif(upper(trim(to_varchar(disp_area))), '') is not null or nullif(upper(trim(to_varchar(disp_other_area))), '') is not null or nullif(upper(trim(to_varchar(disp_city))), '') is not null or nullif(upper(trim(to_varchar(disp_state))), '') is not null or nullif(upper(trim(to_varchar(mailing_pincode))), '') is not null

    union all

    select
        coalesce(nullif(upper(trim(to_varchar(address))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(ins_city))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(ins_state))), ''), '') as parent_bk,
        nullif(upper(trim(to_varchar(address))), '') as address_line_1,
        cast(null as varchar) as address_line_2,
        cast(null as varchar) as building_name,
        nullif(upper(trim(to_varchar(ins_city))), '') as city,
        cast(null as varchar) as country_code,
        cast(null as varchar) as country_name,
        cast(null as varchar) as landmark,
        cast(null as varchar) as locality,
        cast(null as varchar) as post_office_name,
        cast(null as varchar) as postal_code,
        nullif(upper(trim(to_varchar(ins_state))), '') as state_name,
        cast(null as varchar) as street_name,
        cast(null as varchar) as village,
        'BJAZ_TPA_CLAIM_DETAILS_WS (customer)' as record_source
    from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
    where nullif(upper(trim(to_varchar(address))), '') is not null or nullif(upper(trim(to_varchar(ins_city))), '') is not null or nullif(upper(trim(to_varchar(ins_state))), '') is not null

    union all

    select
        coalesce(nullif(upper(trim(to_varchar(hospital_city))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(hospital_state))), ''), '') as parent_bk,
        cast(null as varchar) as address_line_1,
        cast(null as varchar) as address_line_2,
        cast(null as varchar) as building_name,
        nullif(upper(trim(to_varchar(hospital_city))), '') as city,
        cast(null as varchar) as country_code,
        cast(null as varchar) as country_name,
        cast(null as varchar) as landmark,
        cast(null as varchar) as locality,
        cast(null as varchar) as post_office_name,
        cast(null as varchar) as postal_code,
        nullif(upper(trim(to_varchar(hospital_state))), '') as state_name,
        cast(null as varchar) as street_name,
        cast(null as varchar) as village,
        'BJAZ_TPA_CLAIM_DETAILS_WS (hospital)' as record_source
    from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
    where nullif(upper(trim(to_varchar(hospital_city))), '') is not null or nullif(upper(trim(to_varchar(hospital_state))), '') is not null

    union all

    select
        coalesce(nullif(upper(trim(to_varchar(add1))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(add2))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(city))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(state))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(pin))), ''), '') as parent_bk,
        nullif(upper(trim(to_varchar(add1))), '') as address_line_1,
        nullif(upper(trim(to_varchar(add2))), '') as address_line_2,
        cast(null as varchar) as building_name,
        nullif(upper(trim(to_varchar(city))), '') as city,
        cast(null as varchar) as country_code,
        cast(null as varchar) as country_name,
        cast(null as varchar) as landmark,
        cast(null as varchar) as locality,
        cast(null as varchar) as post_office_name,
        nullif(upper(trim(to_varchar(pin))), '') as postal_code,
        nullif(upper(trim(to_varchar(state))), '') as state_name,
        cast(null as varchar) as street_name,
        cast(null as varchar) as village,
        'BJAZ_HM_HCM_EXTRACT (hospital)' as record_source
    from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
    where nullif(upper(trim(to_varchar(add1))), '') is not null or nullif(upper(trim(to_varchar(add2))), '') is not null or nullif(upper(trim(to_varchar(city))), '') is not null or nullif(upper(trim(to_varchar(state))), '') is not null or nullif(upper(trim(to_varchar(pin))), '') is not null

    union all

    select
        coalesce(nullif(upper(trim(to_varchar(address1))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(address2))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(city_name))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(state_name))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(pin_code))), ''), '') as parent_bk,
        nullif(upper(trim(to_varchar(address1))), '') as address_line_1,
        nullif(upper(trim(to_varchar(address2))), '') as address_line_2,
        cast(null as varchar) as building_name,
        nullif(upper(trim(to_varchar(city_name))), '') as city,
        cast(null as varchar) as country_code,
        cast(null as varchar) as country_name,
        cast(null as varchar) as landmark,
        cast(null as varchar) as locality,
        cast(null as varchar) as post_office_name,
        nullif(upper(trim(to_varchar(pin_code))), '') as postal_code,
        nullif(upper(trim(to_varchar(state_name))), '') as state_name,
        cast(null as varchar) as street_name,
        cast(null as varchar) as village,
        'BJAZ_HM_HOSPITAL_MASTER' as record_source
    from {{ ref('stg_health__bjaz_hm_hospital_master') }}
    where nullif(upper(trim(to_varchar(address1))), '') is not null or nullif(upper(trim(to_varchar(address2))), '') is not null or nullif(upper(trim(to_varchar(city_name))), '') is not null or nullif(upper(trim(to_varchar(state_name))), '') is not null or nullif(upper(trim(to_varchar(pin_code))), '') is not null

    union all

    -- Mapper-confirmed 17th branch (MAPPER_REPLY_ADDRESS_REKEY_HEALTH.md): coarse city+state
    -- network location, no street/pincode on this table -- degenerates to a 2-part key.
    select
        coalesce(nullif(upper(trim(to_varchar(network_city))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(state))), ''), '') as parent_bk,
        cast(null as varchar) as address_line_1,
        cast(null as varchar) as address_line_2,
        cast(null as varchar) as building_name,
        nullif(upper(trim(to_varchar(network_city))), '') as city,
        cast(null as varchar) as country_code,
        cast(null as varchar) as country_name,
        cast(null as varchar) as landmark,
        cast(null as varchar) as locality,
        cast(null as varchar) as post_office_name,
        cast(null as varchar) as postal_code,
        nullif(upper(trim(to_varchar(state))), '') as state_name,
        cast(null as varchar) as street_name,
        cast(null as varchar) as village,
        'BJAZ_HM_COINSU_CLM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_coinsu_clm_dtls') }}
    where nullif(upper(trim(to_varchar(network_city))), '') is not null or nullif(upper(trim(to_varchar(state))), '') is not null
)

select * from code_branch
union all
select * from composite_branch
union all
select * from rekey_branch
