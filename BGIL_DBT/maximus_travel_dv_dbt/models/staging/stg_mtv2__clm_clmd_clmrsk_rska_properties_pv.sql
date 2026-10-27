{{ config(materialized='view') }}

-- Layer-1 cast for Maximus Travel V2 source view
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_PROPERTIES_PIVOT_VW
--
-- This view CARRIES MAP ROWS; it is a start view for the key and payload layers.
--
-- Typing: flattened JSON shreds and pivoted EAV views with no source type list, so every
-- value is cast to a trimmed VARCHAR. An absent EAV label on this feed is the EMPTY
-- STRING, not NULL, which is why each value is nullif(trim(...),'') here and why every
-- key is guarded again in mtv2_keyrules.render_key().
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
    nullif(trim(to_varchar("ACCIDENTAL")), '') as accidental,
    nullif(trim(to_varchar("ACTUAL_DATE_OF_ADMISSION_DOA")), '') as actual_date_of_admission_doa,
    nullif(trim(to_varchar("ACTUAL_DATE_OF_DISCHARGE_DOD")), '') as actual_date_of_discharge_dod,
    nullif(trim(to_varchar("ACTUAL_FLIGHT_DATE")), '') as actual_flight_date,
    nullif(trim(to_varchar("ACTUAL_FLIGHT_TIME")), '') as actual_flight_time,
    nullif(trim(to_varchar("ADDITIONAL_AMOUNT_OVER_SI")), '') as additional_amount_over_si,
    nullif(trim(to_varchar("ADVERSE_MEDICAL_HISTORY")), '') as adverse_medical_history,
    nullif(trim(to_varchar("AIRLINES_NAME")), '') as airlines_name,
    nullif(trim(to_varchar("BAGGAGE_DELIVERY_DATE")), '') as baggage_delivery_date,
    nullif(trim(to_varchar("BAGGAGE_DELIVERY_TIME")), '') as baggage_delivery_time,
    nullif(trim(to_varchar("BENEFIT_LIMIT_USD")), '') as benefit_limit_usd,
    nullif(trim(to_varchar("CASE_MANAGEMENT")), '') as case_management,
    nullif(trim(to_varchar("CITY_NAME")), '') as city_name,
    nullif(trim(to_varchar("CLAIM_ADMISSIBLE_COMMENTS_NON_MEDICAL")), '') as claim_admissible_comments_non_medical,
    nullif(trim(to_varchar("CLAIM_ADMISSIBLE_NON_MEDICAL")), '') as claim_admissible_non_medical,
    nullif(trim(to_varchar("COINSURANCE_LOSS_RESERVE_INR")), '') as coinsurance_loss_reserve_inr,
    nullif(trim(to_varchar("COMMENTS")), '') as comments,
    nullif(trim(to_varchar("CONNECTING_FLIGHT_NUMBER")), '') as connecting_flight_number,
    nullif(trim(to_varchar("COUNTRY_OF_LOSS")), '') as country_of_loss,
    nullif(trim(to_varchar("COVER_CODE")), '') as cover_code,
    nullif(trim(to_varchar("COVER_SUM_INSURED")), '') as cover_sum_insured,
    nullif(trim(to_varchar("COVER_SUM_INSURED_CURRENCY")), '') as cover_sum_insured_currency,
    nullif(trim(to_varchar("DATE_OF_INCIDENT")), '') as date_of_incident,
    nullif(trim(to_varchar("DATE_OF_RELEASE")), '') as date_of_release,
    nullif(trim(to_varchar("DEATH_OR_HOSPITALIZATION")), '') as death_or_hospitalization,
    nullif(trim(to_varchar("DECEASED")), '') as deceased,
    nullif(trim(to_varchar("DECEASED_OR_PTD")), '') as deceased_or_ptd,
    nullif(trim(to_varchar("DECEASED_PERSON_INSURED_WITH_BAGIC")), '') as deceased_person_insured_with_bagic,
    nullif(trim(to_varchar("DEDUCTIBLE")), '') as deductible,
    nullif(trim(to_varchar("DEDUCTIBLE_COMMENT")), '') as deductible_comment,
    nullif(trim(to_varchar("DEDUCTIBLE_WAIVED")), '') as deductible_waived,
    nullif(trim(to_varchar("DESCRIPTION_OF_INCIDENT")), '') as description_of_incident,
    nullif(trim(to_varchar("DIFFERENCE_IN_AMOUNT")), '') as difference_in_amount,
    nullif(trim(to_varchar("DISEASE_CATEGORY")), '') as disease_category,
    nullif(trim(to_varchar("DO_YO_WANT_TO_SAVE_NON_MEDICAL_DETAILS")), '') as do_yo_want_to_save_non_medical_details,
    nullif(trim(to_varchar("EVENT_DATE")), '') as event_date,
    nullif(trim(to_varchar("FINAL_DIAGNOSIS")), '') as final_diagnosis,
    nullif(trim(to_varchar("FIR")), '') as fir,
    nullif(trim(to_varchar("FIR_DATE")), '') as fir_date,
    nullif(trim(to_varchar("FIR_TIME")), '') as fir_time,
    nullif(trim(to_varchar("FLIGHT_DATE")), '') as flight_date,
    nullif(trim(to_varchar("FLIGHT_DELAY")), '') as flight_delay,
    nullif(trim(to_varchar("FLIGHT_END_DATE")), '') as flight_end_date,
    nullif(trim(to_varchar("FLIGHT_END_TIME")), '') as flight_end_time,
    nullif(trim(to_varchar("FLIGHT_NAME")), '') as flight_name,
    nullif(trim(to_varchar("FLIGHT_NUMBER")), '') as flight_number,
    nullif(trim(to_varchar("FLIGHT_TIME")), '') as flight_time,
    nullif(trim(to_varchar("GENERAL_TEAM_COMMENTS_TRACKING_COMMENTS")), '') as general_team_comments_tracking_comments,
    nullif(trim(to_varchar("GROUND_OF_REJECTION")), '') as ground_of_rejection,
    nullif(trim(to_varchar("HOSPITALIZATION_DAYS")), '') as hospitalization_days,
    nullif(trim(to_varchar("HOSPITAL_ADDRESS")), '') as hospital_address,
    nullif(trim(to_varchar("HOSPITAL_CONTACT_NO")), '') as hospital_contact_no,
    nullif(trim(to_varchar("HOSPITAL_COUNTRY")), '') as hospital_country,
    nullif(trim(to_varchar("HOSPITAL_ID")), '') as hospital_id,
    nullif(trim(to_varchar("HOSPITAL_NAME")), '') as hospital_name,
    nullif(trim(to_varchar("ICD_DESCRIPTION")), '') as icd_description,
    nullif(trim(to_varchar("ILM_CASE_STATUS")), '') as ilm_case_status,
    nullif(trim(to_varchar("ILM_INTERIM_UPDATE")), '') as ilm_interim_update,
    nullif(trim(to_varchar("INVESTIGATION_FINDINGS")), '') as investigation_findings,
    nullif(trim(to_varchar("INVESTIGATION_NUMBER")), '') as investigation_number,
    nullif(trim(to_varchar("IS_EXTENSIONS_CLAUSES_CONDITIONS_AND_WARRANTIES_APPLICABLE")), '') as is_extensions_clauses_conditions_and_warranties_applicable,
    nullif(trim(to_varchar("LINKED_DELAY_OF_BAGGAGE_CLAIM")), '') as linked_delay_of_baggage_claim,
    nullif(trim(to_varchar("LINKED_HEALTH_CLAIM")), '') as linked_health_claim,
    nullif(trim(to_varchar("LINKED_TRIP_DELAY_CLAIM_NUMBER")), '') as linked_trip_delay_claim_number,
    nullif(trim(to_varchar("LINKED_TRIP_DELAY_CLAIM_PAYABLE")), '') as linked_trip_delay_claim_payable,
    nullif(trim(to_varchar("LOCATION")), '') as location,
    nullif(trim(to_varchar("LOSS_AMOUNT")), '') as loss_amount,
    nullif(trim(to_varchar("LOSS_AMOUNT_CURRENCY")), '') as loss_amount_currency,
    nullif(trim(to_varchar("LOSS_AMOUNT_IN_INR")), '') as loss_amount_in_inr,
    nullif(trim(to_varchar("LOSS_RESERVE_INR")), '') as loss_reserve_inr,
    nullif(trim(to_varchar("MEDICAL_COMMENTS")), '') as medical_comments,
    nullif(trim(to_varchar("MODE_OF_TRAVEL")), '') as mode_of_travel,
    nullif(trim(to_varchar("MODE_OF_TREATMENT")), '') as mode_of_treatment,
    nullif(trim(to_varchar("MODIFIED_RESERVE_AGAINST_LOSS_COMPENSATION")), '') as modified_reserve_against_loss_compensation,
    nullif(trim(to_varchar("NON_DISCLOSURE")), '') as non_disclosure,
    nullif(trim(to_varchar("NUMBER_OF_BAGS")), '') as number_of_bags,
    nullif(trim(to_varchar("ORIGINAL_DATE")), '') as original_date,
    nullif(trim(to_varchar("PANDEMIC_COVER_FLAG")), '') as pandemic_cover_flag,
    nullif(trim(to_varchar("PCS_DESCREPTION")), '') as pcs_descreption,
    nullif(trim(to_varchar("PERCENTAGE_OF_DISABILITY")), '') as percentage_of_disability,
    nullif(trim(to_varchar("PERTINENT_PERSON_INSUREDSPOUSECHILDREN")), '') as pertinent_person_insuredspousechildren,
    nullif(trim(to_varchar("PREEXISTING")), '') as preexisting,
    nullif(trim(to_varchar("PREEXISTING_DESCRIPTION")), '') as preexisting_description,
    nullif(trim(to_varchar("PREEXISTING_ILLNESS")), '') as preexisting_illness,
    nullif(trim(to_varchar("PURPOSE_OF_VISIT")), '') as purpose_of_visit,
    nullif(trim(to_varchar("REASON")), '') as reason,
    nullif(trim(to_varchar("RESCHEDULED_DATE")), '') as rescheduled_date,
    nullif(trim(to_varchar("RESCHEDULED_FLIGHT_CLASS")), '') as rescheduled_flight_class,
    nullif(trim(to_varchar("SEVERITY_OF_FRAUD")), '') as severity_of_fraud,
    nullif(trim(to_varchar("SI_VALIDATION_OVERRIDE")), '') as si_validation_override,
    nullif(trim(to_varchar("SI_VALIDATION_OVERRIDE_REMARKS")), '') as si_validation_override_remarks,
    nullif(trim(to_varchar("SUBCOVER_CODE")), '') as subcover_code,
    nullif(trim(to_varchar("SUBCOVER_NAME")), '') as subcover_name,
    nullif(trim(to_varchar("SUBCOVER_SI_AMOUNT")), '') as subcover_si_amount,
    nullif(trim(to_varchar("SUBLIMIT")), '') as sublimit,
    nullif(trim(to_varchar("SYSTEM_OF_MEDICINE")), '') as system_of_medicine,
    nullif(trim(to_varchar("TIME_OF_INCIDENT")), '') as time_of_incident,
    nullif(trim(to_varchar("TIME_OF_RELEASE")), '') as time_of_release,
    nullif(trim(to_varchar("TOTAL_DURATION")), '') as total_duration,
    nullif(trim(to_varchar("TREATING_DOCTOR_DETAILS")), '') as treating_doctor_details,
    nullif(trim(to_varchar("TRIP_END_COUNTRY")), '') as trip_end_country,
    nullif(trim(to_varchar("TTDPTD")), '') as ttdptd,
    nullif(trim(to_varchar("TYPE")), '') as type,
    nullif(trim(to_varchar("TYPE_OF_TRANSPORT")), '') as type_of_transport,
    nullif(trim(to_varchar("VENDOR_SCORE")), '') as vendor_score,
    nullif(trim(to_varchar("WEATHER_CONDITION")), '') as weather_condition,
    nullif(trim(to_varchar("WHO_IS_AT_FAULT")), '') as who_is_at_fault
    from {{ source('maximus_travel_v2_raw', 'NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_PROPERTIES_PIVOT_VW') }}

)

select * from source
