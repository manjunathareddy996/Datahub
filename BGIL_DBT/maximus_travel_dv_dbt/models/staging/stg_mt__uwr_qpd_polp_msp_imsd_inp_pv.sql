{{ config(materialized='view') }}

-- Layer-1 cast for Maximus Travel source view
--   NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW
--
-- This view CARRIES MAP ROWS; it is a start view for the key and payload layers.
--
-- Typing: flattened JSON shreds and pivoted EAV views with no source type list, so every
-- value is cast to a trimmed VARCHAR. An absent EAV label on this feed is the EMPTY
-- STRING, not NULL, which is why each value is nullif(trim(...),'') here and why every
-- key is guarded again in mt_keyrules.render_key().
--
-- Every source identifier is DOUBLE-QUOTED (directive D-QUOTE): seven column names in
-- this feed begin with a digit and do not compile unquoted. Their aliases carry a col_
-- prefix for the same reason -- an alias may not begin with a digit either.
--
-- Shred lineage carried through deliberately (FOREIGN_KEY, KEY_HASH, PARENT_KEY_HASH, PARENT_RECORD_HASH): it appears in no row of the map and
-- the whole sub-document key layer is built on it.

with source as (

    select
    "FOREIGN_KEY" as foreign_key,
    "PARENT_RECORD_HASH" as parent_record_hash,
    "PARENT_KEY_HASH" as parent_key_hash,
    "KEY_HASH" as key_hash,
    try_to_timestamp_ntz(trim(to_varchar("INC_JOB_CREATED_AT"))) as inc_job_created_at,
    nullif(trim(to_varchar("REC_REFRESH_AT")), '') as rec_refresh_at,
    nullif(trim(to_varchar("ACE_DURATION")), '') as ace_duration,
    nullif(trim(to_varchar("ACE_PREMIUM_TYPE")), '') as ace_premium_type,
    nullif(trim(to_varchar("AGE_GROUP")), '') as age_group,
    nullif(trim(to_varchar("ALLOCATION_PERCENTAGE")), '') as allocation_percentage,
    nullif(trim(to_varchar("AMBULANCE_SUB_COVER")), '') as ambulance_sub_cover,
    nullif(trim(to_varchar("APPOINTEE_NAME")), '') as appointee_name,
    nullif(trim(to_varchar("ARRIVAL_COUNTRY")), '') as arrival_country,
    nullif(trim(to_varchar("ARRIVAL_DATE")), '') as arrival_date,
    nullif(trim(to_varchar("ARRIVAL_TIME")), '') as arrival_time,
    nullif(trim(to_varchar("BENEFIT_AMOUNT")), '') as benefit_amount,
    nullif(trim(to_varchar("CANCELLATION_MAIN_SUB_COVER")), '') as cancellation_main_sub_cover,
    nullif(trim(to_varchar("CANCELLATION_SUB_COVER")), '') as cancellation_sub_cover,
    nullif(trim(to_varchar("CLAIMS_PAID")), '') as claims_paid,
    nullif(trim(to_varchar("CLAIM_EXPENSES")), '') as claim_expenses,
    nullif(trim(to_varchar("CLAIM_OUTSTANDING")), '') as claim_outstanding,
    nullif(trim(to_varchar("CURRENT_MEDICATION")), '') as current_medication,
    nullif(trim(to_varchar("DATE_AND_TIME")), '') as date_and_time,
    nullif(trim(to_varchar("DATE_OF_BIRTH")), '') as date_of_birth,
    nullif(trim(to_varchar("DEDUCTIBLE_VALUE_SUBLIMIT")), '') as deductible_value_sublimit,
    nullif(trim(to_varchar("DELAY_EXCEEDING")), '') as delay_exceeding,
    nullif(trim(to_varchar("DELAY_EXCEEDING_ACE")), '') as delay_exceeding_ace,
    nullif(trim(to_varchar("DEPARTURE_AIRPORT_CODE")), '') as departure_airport_code,
    nullif(trim(to_varchar("DEPARTURE_COUNTRY")), '') as departure_country,
    nullif(trim(to_varchar("DEPARTURE_DATE")), '') as departure_date,
    nullif(trim(to_varchar("DEPARTURE_TIME")), '') as departure_time,
    nullif(trim(to_varchar("DESTINATION_CONTINENT")), '') as destination_continent,
    nullif(trim(to_varchar("DESTINATION_COUNTRY")), '') as destination_country,
    nullif(trim(to_varchar("DISEASE")), '') as disease,
    nullif(trim(to_varchar("DISEASE_DESCRIPTION")), '') as disease_description,
    nullif(trim(to_varchar("DURATION_TYPE")), '') as duration_type,
    nullif(trim(to_varchar("ENDORSEMENT_TYPE")), '') as endorsement_type,
    nullif(trim(to_varchar("EXCLUDED_COUNTRIES")), '') as excluded_countries,
    nullif(trim(to_varchar("EXCLUDED_EVENTS")), '') as excluded_events,
    nullif(trim(to_varchar("FIXED_ONE_WAY_PREMIUM")), '') as fixed_one_way_premium,
    nullif(trim(to_varchar("FIXED_ROUND_TRIP_PREMIUM")), '') as fixed_round_trip_premium,
    nullif(trim(to_varchar("FLIGHT_NO")), '') as flight_no,
    nullif(trim(to_varchar("GEOGRAPHICAL_COVERAGE")), '') as geographical_coverage,
    nullif(trim(to_varchar("GROSS_PREMIUM")), '') as gross_premium,
    nullif(trim(to_varchar("INCONVENIENCE_SUB_COVER")), '') as inconvenience_sub_cover,
    nullif(trim(to_varchar("ITEMS_COVERED")), '') as items_covered,
    nullif(trim(to_varchar("LIMIT_SUM_INSURED")), '') as limit_sum_insured,
    nullif(trim(to_varchar("LOADING_ACE")), '') as loading_ace,
    nullif(trim(to_varchar("LOADING_ACE_FOR_MAIN_SUB_COVER")), '') as loading_ace_for_main_sub_cover,
    nullif(trim(to_varchar("NOMINEE_NAME")), '') as nominee_name,
    nullif(trim(to_varchar("OFFICE_PREMIUM_PER_MILLE_PA")), '') as office_premium_per_mille_pa,
    nullif(trim(to_varchar("OFFICE_PREMIUM_PER_MILLE_PER_TRIP")), '') as office_premium_per_mille_per_trip,
    nullif(trim(to_varchar("ONE_WAY_PREMIUM")), '') as one_way_premium,
    nullif(trim(to_varchar("ONWARD_RETURN")), '') as onward_return,
    nullif(trim(to_varchar("PED_MONTH")), '') as ped_month,
    nullif(trim(to_varchar("PED_YEAR")), '') as ped_year,
    nullif(trim(to_varchar("PERIOD")), '') as period,
    nullif(trim(to_varchar("PNR")), '') as pnr,
    nullif(trim(to_varchar("PREMIUM_RATE")), '') as premium_rate,
    nullif(trim(to_varchar("QUERY_CODE")), '') as query_code,
    nullif(trim(to_varchar("QUERY_DETAILS")), '') as query_details,
    nullif(trim(to_varchar("QUERY_REPLY")), '') as query_reply,
    nullif(trim(to_varchar("QUERY_STATUS")), '') as query_status,
    nullif(trim(to_varchar("QUERY_TYPE")), '') as query_type,
    nullif(trim(to_varchar("RAISED_BYUSER")), '') as raised_byuser,
    nullif(trim(to_varchar("RAISED_BY_ROLE")), '') as raised_by_role,
    nullif(trim(to_varchar("RATE_PER_TRIP_PER_MILLE")), '') as rate_per_trip_per_mille,
    nullif(trim(to_varchar("RATE_PER_TRIP_PER_MILLE_FOR_MAIN_SUB_COVER")), '') as rate_per_trip_per_mille_for_main_sub_cover,
    nullif(trim(to_varchar("REFERENCE_NUMBER")), '') as reference_number,
    nullif(trim(to_varchar("REF_TYPE")), '') as ref_type,
    nullif(trim(to_varchar("RELATION_WITH_INSURED")), '') as relation_with_insured,
    nullif(trim(to_varchar("REPLIED_BY_ROLE")), '') as replied_by_role,
    nullif(trim(to_varchar("REPLIED_BY_USER")), '') as replied_by_user,
    nullif(trim(to_varchar("REPLY_DATE_AND_TIME")), '') as reply_date_and_time,
    nullif(trim(to_varchar("RETURN_DATE")), '') as return_date,
    nullif(trim(to_varchar("ROUND_TRIP_PREMIUM")), '') as round_trip_premium,
    nullif(trim(to_varchar("SERIAL_NO")), '') as serial_no,
    nullif(trim(to_varchar("SLAB_")), '') as slab_,
    nullif(trim(to_varchar("SR_NUMBER")), '') as sr_number,
    nullif(trim(to_varchar("STANDARD_FIRE_AND_SPECIAL_PERILS_SUB_COVER")), '') as standard_fire_and_special_perils_sub_cover,
    nullif(trim(to_varchar("SUBLIMIT_NAME")), '') as sublimit_name,
    nullif(trim(to_varchar("SUM_INSURED")), '') as sum_insured,
    nullif(trim(to_varchar("SUM_INSUREDACE")), '') as sum_insuredace,
    nullif(trim(to_varchar("SUM_INSURED_ACE")), '') as sum_insured_ace,
    nullif(trim(to_varchar("SUM_INSURED_ACE_FOR_MAIN_SUB_COVER")), '') as sum_insured_ace_for_main_sub_cover,
    nullif(trim(to_varchar("TRAVEL_DATE")), '') as travel_date,
    nullif(trim(to_varchar("TRIP_DURATION_IN_DAYS")), '') as trip_duration_in_days,
    nullif(trim(to_varchar("TRIP_NO")), '') as trip_no,
    nullif(trim(to_varchar("TRIP_TYPE_INCOV")), '') as trip_type_incov,
    nullif(trim(to_varchar("TRIP_TYPE_TRIPCAL")), '') as trip_type_tripcal,
    nullif(trim(to_varchar("YEAR")), '') as year
    from {{ source('maximus_travel_raw', 'NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW') }}

)

select * from source
