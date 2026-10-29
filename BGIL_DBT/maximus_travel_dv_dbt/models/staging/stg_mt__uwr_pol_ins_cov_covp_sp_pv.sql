{{ config(materialized='view') }}

-- Layer-1 cast for Maximus Travel source view
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
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
    nullif(trim(to_varchar("UNNAMED_COLUMN_ORD7")), '') as unnamed_column_ord7,
    nullif(trim(to_varchar("ACCIDENTAL_PREMIUMACE")), '') as accidental_premiumace,
    nullif(trim(to_varchar("AMBULANCE_SUBCOVER")), '') as ambulance_subcover,
    nullif(trim(to_varchar("BASE_AMT_ON_CURRENT_PMM_SLAB")), '') as base_amt_on_current_pmm_slab,
    nullif(trim(to_varchar("BASIS_OF_DEDUCTIBLE")), '') as basis_of_deductible,
    nullif(trim(to_varchar("CANCELLATION_SUBCOVER")), '') as cancellation_subcover,
    nullif(trim(to_varchar("COMMERCIAL_PREMIUM")), '') as commercial_premium,
    nullif(trim(to_varchar("COMMON_CARRIER_RELATIVITY")), '') as common_carrier_relativity,
    nullif(trim(to_varchar("COMMON_CARRIER_TYPE")), '') as common_carrier_type,
    nullif(trim(to_varchar("COPAYACE")), '') as copayace,
    nullif(trim(to_varchar("COVER_DESCRIPTION")), '') as cover_description,
    nullif(trim(to_varchar("COVER_DESCRIPTION_MANUAL")), '') as cover_description_manual,
    nullif(trim(to_varchar("COVER_EXPIRY_DATE")), '') as cover_expiry_date,
    nullif(trim(to_varchar("COVER_INCEPTION_DATE")), '') as cover_inception_date,
    nullif(trim(to_varchar("COVER_LEVEL_BASE_CURRENCY")), '') as cover_level_base_currency,
    nullif(trim(to_varchar("COVER_LEVEL_FAC_RI")), '') as cover_level_fac_ri,
    nullif(trim(to_varchar("COVER_LEVEL_FAC_RI_PERCENTAGE")), '') as cover_level_fac_ri_percentage,
    nullif(trim(to_varchar("COVER_LEVEL_TRANSACTION_CURRENCY")), '') as cover_level_transaction_currency,
    nullif(trim(to_varchar("COVER_LEVEL_TRANSACTION_CURRENCY_FOR_SUM_INSURED")), '') as cover_level_transaction_currency_for_sum_insured,
    nullif(trim(to_varchar("COVER_PLAN")), '') as cover_plan,
    nullif(trim(to_varchar("COVER_PREMIUM_IN_BASE_CURRENCY")), '') as cover_premium_in_base_currency,
    nullif(trim(to_varchar("COVER_PREMIUM_IN_TRANSACTION_CURRENCY")), '') as cover_premium_in_transaction_currency,
    nullif(trim(to_varchar("COVER_SUM_INSURED_IN_BASE_CURRENCY")), '') as cover_sum_insured_in_base_currency,
    nullif(trim(to_varchar("COVER_SUM_INSURED_IN_TRANSACTION_CURRENCY")), '') as cover_sum_insured_in_transaction_currency,
    nullif(trim(to_varchar("DEDUCTIBLE")), '') as deductible,
    nullif(trim(to_varchar("DEDUCTIBLEACE")), '') as deductibleace,
    nullif(trim(to_varchar("DEDUCTIBLE_BASIS")), '') as deductible_basis,
    nullif(trim(to_varchar("DEDUCTIBLE_VALUE")), '') as deductible_value,
    nullif(trim(to_varchar("DEDUCTIBLE_VALUE_FOR_ABROAD")), '') as deductible_value_for_abroad,
    nullif(trim(to_varchar("DEDUCTIBLE_VALUE_FOR_INDIA")), '') as deductible_value_for_india,
    nullif(trim(to_varchar("EMERGENCY_HOSPITALIZATION_FOR_SICKNESS_PREMIUM")), '') as emergency_hospitalization_for_sickness_premium,
    nullif(trim(to_varchar("FOREX_RATE_AT_COVER_LEVEL")), '') as forex_rate_at_cover_level,
    nullif(trim(to_varchar("INCONVENIENCE_SUBCOVER")), '') as inconvenience_subcover,
    nullif(trim(to_varchar("LOADING")), '') as loading,
    nullif(trim(to_varchar("LOADINGACE")), '') as loadingace,
    nullif(trim(to_varchar("MAXIMUM_PERIODDAYS")), '') as maximum_perioddays,
    nullif(trim(to_varchar("MAXIMUM_SUM_INSURED")), '') as maximum_sum_insured,
    nullif(trim(to_varchar("MINIMUM_PREMIUM")), '') as minimum_premium,
    nullif(trim(to_varchar("NET_PREMIUM")), '') as net_premium,
    nullif(trim(to_varchar("NET_PREMIUM_WITHOUT_LOADING_DISCOUNT")), '') as net_premium_without_loading_discount,
    nullif(trim(to_varchar("NUMBER_OF_DAYS")), '') as number_of_days,
    nullif(trim(to_varchar("NUMBER_OF_WEEKS")), '') as number_of_weeks,
    nullif(trim(to_varchar("OFFICE_PREMIUM_PA")), '') as office_premium_pa,
    nullif(trim(to_varchar("OFFICE_PREMIUM_PER_MILE")), '') as office_premium_per_mile,
    nullif(trim(to_varchar("OFFICE_PREMIUM_PER_MILELOADING")), '') as office_premium_per_mileloading,
    nullif(trim(to_varchar("OFFICE_PREMIUM_PER_MILLE_ACCIDENT_ONLY")), '') as office_premium_per_mille_accident_only,
    nullif(trim(to_varchar("OFFICE_PREMIUM_PER_MILLE_EMERGENCY_OPD_EXPENSES_FOR_SICKNESS")), '') as office_premium_per_mille_emergency_opd_expenses_for_sickness,
    nullif(trim(to_varchar("OFFICE_PREMIUM_PER_MILLE_PA")), '') as office_premium_per_mille_pa,
    nullif(trim(to_varchar("OFFICE_PREMIUM_PER_MILLE_PA_ACCIDENT_ONLY")), '') as office_premium_per_mille_pa_accident_only,
    nullif(trim(to_varchar("OFFICE_PREMIUM_PER_MILLE_PA_AIR_AMBULANCE")), '') as office_premium_per_mille_pa_air_ambulance,
    nullif(trim(to_varchar("OFFICE_PREMIUM_PER_MILLE_PA_DEATH")), '') as office_premium_per_mille_pa_death,
    nullif(trim(to_varchar("OFFICE_PREMIUM_PER_MILLE_PA_FOR_SICKNESS_ONLY")), '') as office_premium_per_mille_pa_for_sickness_only,
    nullif(trim(to_varchar("OFFICE_PREMIUM_PER_MILLE_PA_FRACTURE_CARE_BENEFIT")), '') as office_premium_per_mille_pa_fracture_care_benefit,
    nullif(trim(to_varchar("OFFICE_PREMIUM_PER_MILLE_PA_PPD")), '') as office_premium_per_mille_pa_ppd,
    nullif(trim(to_varchar("OFFICE_PREMIUM_PER_MILLE_PA_PTD")), '') as office_premium_per_mille_pa_ptd,
    nullif(trim(to_varchar("OFFICE_PREMIUM_PER_MILLE_PA_REPATRIATION_OF_MORTAL_REMAINS")), '') as office_premium_per_mille_pa_repatriation_of_mortal_remains,
    nullif(trim(to_varchar("OFFICE_PREMIUM_PER_MILLE_PA_REPLACEMENT_AND_REARRANGEMENT_OF_STAFF")), '') as office_premium_per_mille_pa_replacement_and_rearrangement_of_staff,
    nullif(trim(to_varchar("OFFICE_PREMIUM_PER_MILLE_PA_ROAD")), '') as office_premium_per_mille_pa_road,
    nullif(trim(to_varchar("OFFICE_PREMIUM_PER_MILLE_PER_TRIP")), '') as office_premium_per_mille_per_trip,
    nullif(trim(to_varchar("OLD_PREMIUM")), '') as old_premium,
    nullif(trim(to_varchar("PAYOUT_OPTIONACE")), '') as payout_optionace,
    nullif(trim(to_varchar("PERIOD")), '') as period,
    nullif(trim(to_varchar("PMM_ADJ_FACTOR_FOR_PRD_ELAPSED")), '') as pmm_adj_factor_for_prd_elapsed,
    nullif(trim(to_varchar("PMM_ADJ_FACTOR_FOR_PRD_REMAIN")), '') as pmm_adj_factor_for_prd_remain,
    nullif(trim(to_varchar("PMM_ADJ_FACTOR_FOR_PRODUCT_REMAIN")), '') as pmm_adj_factor_for_product_remain,
    nullif(trim(to_varchar("PREMIUM")), '') as premium,
    nullif(trim(to_varchar("PREMIUM_PER_DAY")), '') as premium_per_day,
    nullif(trim(to_varchar("RATE")), '') as rate,
    nullif(trim(to_varchar("RATEACE_DOMESTIC")), '') as rateace_domestic,
    nullif(trim(to_varchar("RATE_BASISACE_DOMESTIC")), '') as rate_basisace_domestic,
    nullif(trim(to_varchar("RATE_FOR_DAILY_ALLOWANCE_PA")), '') as rate_for_daily_allowance_pa,
    nullif(trim(to_varchar("RELATIVITYACE")), '') as relativityace,
    nullif(trim(to_varchar("RISK_FACTORACE")), '') as risk_factorace,
    nullif(trim(to_varchar("RISK_LOAD_FACTORACE")), '') as risk_load_factorace,
    nullif(trim(to_varchar("SHORT_TERM_FACTORACE")), '') as short_term_factorace,
    nullif(trim(to_varchar("SI_FOR_ABROAD_IN_USD")), '') as si_for_abroad_in_usd,
    nullif(trim(to_varchar("SI_FOR_INDIA_IN_INR")), '') as si_for_india_in_inr,
    nullif(trim(to_varchar("SI_PER_UNIT")), '') as si_per_unit,
    nullif(trim(to_varchar("SLAB_DETAILS")), '') as slab_details,
    nullif(trim(to_varchar("SUBLIMIT_DETAILS")), '') as sublimit_details,
    nullif(trim(to_varchar("SUB_CONDITION1")), '') as sub_condition1,
    nullif(trim(to_varchar("SUM_INSURED")), '') as sum_insured,
    nullif(trim(to_varchar("SUM_INSUREDACE")), '') as sum_insuredace,
    nullif(trim(to_varchar("SUM_INSURED_BREAK_UP")), '') as sum_insured_break_up,
    nullif(trim(to_varchar("TOTAL_SUM_INSURED")), '') as total_sum_insured,
    nullif(trim(to_varchar("TRIP_COVERAGE")), '') as trip_coverage,
    nullif(trim(to_varchar("TRIP_DELAY_OPTION")), '') as trip_delay_option,
    nullif(trim(to_varchar("TRIP_DURATIONACE")), '') as trip_durationace,
    nullif(trim(to_varchar("TRIP_TYPEACE_DOMESTIC")), '') as trip_typeace_domestic,
    nullif(trim(to_varchar("UNIT_IN_HOURS")), '') as unit_in_hours,
    nullif(trim(to_varchar("UPDATE_COVER_PREMIUM_IN_BASE_CURRENCY")), '') as update_cover_premium_in_base_currency,
    nullif(trim(to_varchar("UPDATE_FOREX_RATE")), '') as update_forex_rate
    from {{ source('maximus_travel_raw', 'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW') }}

)

select * from source
