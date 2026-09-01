{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL stitch: the ONE genuine join needed anywhere in this LOB build
-- (every other satellite here is a plain per-table union -- see README Architecture
-- section for why). Full passthrough of BJAZ_TRV_LOADER_DATA_MV's own traveller
-- columns (policy_ref, each MEMBERn's passport number, and the 5 non-MemberN-prefixed
-- trip columns -- see Fix A note below) PLUS BA_TRV_DATA_POLICY_DTLS_MV's trip
-- attributes joined on POLICY_REF (round 3, mapper-confirmed: both tables carry the
-- same POLICY_REF, same value space -- 'BUILDABLE (same-named policy key on both)').
-- LEFT JOIN from the loader-data side so every traveller-bearing policy is preserved
-- even where no matching BA_TRV_DATA_POLICY_DTLS_MV row exists. Attribute-level
-- COALESCE between the two sources happens downstream, per-attribute, in each member's
-- stage() (see stg2_risk_person_travel_bjaz_trv_loader_data_mv_memberN.sql) -- kept out
-- of this stitch since AutomateDV's hashing/derivation happens at the stage() layer,
-- not here (this view stays raw, zero hashing, matching the Health/Partner convention).
--
-- Fix A (self-caught, not from the mapper): AREAPLAN/DEPARTUREDATE/NOOFJOURNEYDAYS/
-- PRJOURNEY/RETURNDATE are valid mapped columns with no MemberN prefix -- the original
-- per-member generator only matched columns literally containing 'MEMBERn', so these 5
-- were silently never built at all (not even flagged as a gap). Passed through here so
-- every member's stage can fan them out identically.

with loader as (

    select
        policy_ref,
        member1passportno,
        member2passportno,
        member3passportno,
        member4passportno,
        member5passportno,
        areaplan,
        departuredate,
        noofjourneydays,
        prjourney,
        returndate
    from {{ ref('stg_travel__bjaz_trv_loader_data_mv') }}

),

trip_attrs as (

    select
        policy_ref,
        destination,
        no_of_days,
        travel_area_plan_nm,
        travel_area_plan_no,
        type_of_visa
    from {{ ref('stg_travel__ba_trv_data_policy_dtls_mv') }}

)

select
    loader.policy_ref,
    loader.member1passportno,
    loader.member2passportno,
    loader.member3passportno,
    loader.member4passportno,
    loader.member5passportno,
    loader.areaplan,
    loader.departuredate,
    loader.noofjourneydays,
    loader.prjourney,
    loader.returndate,
    trip_attrs.destination,
    trip_attrs.no_of_days,
    trip_attrs.travel_area_plan_nm,
    trip_attrs.travel_area_plan_no,
    trip_attrs.type_of_visa
from loader
left join trip_attrs on loader.policy_ref = trip_attrs.policy_ref
