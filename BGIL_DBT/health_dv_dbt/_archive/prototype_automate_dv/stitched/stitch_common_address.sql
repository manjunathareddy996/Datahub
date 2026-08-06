{{ config(materialized='view') }}

-- PROTOTYPE (AutomateDV evaluation) -- see docs/prototype_automate_dv/README.md.
-- The one genuine exception to "stage() per table, feed hub/link/sat directly": SAT_COMMON_
-- ADDRESS needs ATTRIBUTE-LEVEL merging (one table might have city but not postcode for the
-- same location, both need to land on the same output row), not just row-stacking. AutomateDV
-- has no macro for that -- hub()/link()'s automatic union only stacks whole rows, it doesn't
-- coalesce columns across sources.
--
-- Reads the 3 code-keyed tables' RAW production staging directly (stg_health__*, the plain
-- 1:1 cast layer, not an AutomateDV stage()) and joins on the RAW business key (RISK_LOCATION
-- / POLICY_LOCATION / PIN_CODE). No per-table stage() exists for these 3 tables -- there is
-- nothing to hash until AFTER this join produces one clean row per location. Hashing happens
-- exactly once, downstream, in stg2_common_address_stitched.sql.
--
-- The 4 party-address tables are only UNION'd in below (composite_branch), not joined against
-- the code-keyed tables -- so unlike the code-keyed 3, they're read from their OWN per-table
-- stage() outputs (already built for HUB_PARTY / SAT_PARTY_ADDRESS_USAGE), taking their raw
-- LOCATION_CODE_KEY (not the already-hashed LOCATION_HK) so both branches land in the same
-- unhashed shape before the one downstream hashing pass.
--
-- 2 joins (code_branch) + 1 union (composite rows, disjoint key domain, safe to stack).

with t0 as (
    select distinct
        risk_location as location_code_key,
        nullif(trim(to_varchar(address_line1)), '') as address_line_1,
        nullif(trim(to_varchar(address_line2)), '') as address_line_2,
        nullif(trim(to_varchar(city)), '') as city,
        nullif(trim(to_varchar(state)), '') as state_code,
        nullif(trim(to_varchar(postcode)), '') as postal_code
    from {{ ref('stg_health__bjaz_ehh_pol_dtls') }}
    where risk_location is not null
    qualify row_number() over (partition by location_code_key order by address_line_1, city, postal_code) = 1
),
t1 as (
    select distinct
        policy_location as location_code_key,
        nullif(trim(to_varchar(patient_address)), '') as address_line_1
    from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
    where policy_location is not null
    qualify row_number() over (partition by location_code_key order by address_line_1) = 1
),
t2 as (
    select distinct
        pin_code as location_code_key,
        nullif(trim(to_varchar(address1)), '') as address_line_1,
        nullif(trim(to_varchar(address2)), '') as address_line_2,
        nullif(trim(to_varchar(city_name)), '') as city,
        nullif(trim(to_varchar(state_name)), '') as state_code,
        nullif(trim(to_varchar(pin_code)), '') as postal_code
    from {{ ref('stg_health__bjaz_hm_hospital_master') }}
    where pin_code is not null
    qualify row_number() over (partition by location_code_key order by address_line_1, city, postal_code) = 1
),

code_branch as (
    select
        coalesce(t0.location_code_key, t1.location_code_key, t2.location_code_key) as location_code_key,
        coalesce(t0.address_line_1, t1.address_line_1, t2.address_line_1) as address_line_1,
        coalesce(t0.address_line_2, t2.address_line_2) as address_line_2,
        coalesce(t0.city, t2.city) as city,
        coalesce(t0.state_code, t2.state_code) as state_code,
        coalesce(t0.postal_code, t2.postal_code) as postal_code,
        array_to_string(array_construct_compact(
            case when t0.location_code_key is not null then 'BJAZ_EHH_POL_DTLS' end,
            case when t1.location_code_key is not null then 'BJAZ_HM_HCM_EXTRACT' end,
            case when t2.location_code_key is not null then 'BJAZ_HM_HOSPITAL_MASTER' end
        ), ', ') as record_source
    from t0
    full outer join t1 on t0.location_code_key = t1.location_code_key
    full outer join t2 on coalesce(t0.location_code_key, t1.location_code_key) = t2.location_code_key
),

composite_branch as (
    select location_code_key, address_line_1, address_line_2, city, state_code, postal_code, record_source
    from {{ ref('stg2_ba_hcp_pp_mem_dtls') }}
    union all
    select location_code_key, address_line_1, address_line_2, city, state_code, postal_code, record_source
    from {{ ref('stg2_bjaz_bandhan_medi_clam_address') }}
    union all
    select location_code_key, address_line_1, address_line_2, city, state_code, postal_code, record_source
    from {{ ref('stg2_bjaz_hat_id_mem_detls') }}
    union all
    select location_code_key, address_line_1, address_line_2, city, state_code, postal_code, record_source
    from {{ ref('stg2_bjaz_tpa_claim_details_ws_payee') }}
)

select * from code_branch
union all
select * from composite_branch
