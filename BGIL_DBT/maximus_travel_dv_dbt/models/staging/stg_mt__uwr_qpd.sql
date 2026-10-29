{{ config(materialized='view') }}

-- Layer-1 cast for Maximus Travel source view
--   NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS
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
-- Shred lineage carried through deliberately (FOREIGN_KEY, KEY_HASH, PARENT_KEY_HASH, ROOT_HASH, RECORD_HASH, PARENT_RECORD_HASH, PARENT_TABLE_NAME): it appears in no row of the map and
-- the whole sub-document key layer is built on it.

with source as (

    select
    "FOREIGN_KEY" as foreign_key,
    "ROOT_HASH" as root_hash,
    "PARENT_KEY_HASH" as parent_key_hash,
    "PARENT_RECORD_HASH" as parent_record_hash,
    "KEY_HASH" as key_hash,
    "RECORD_HASH" as record_hash,
    "PARENT_TABLE_NAME" as parent_table_name,
    try_to_timestamp_ntz(trim(to_varchar("INC_JOB_CREATED_AT"))) as inc_job_created_at,
    nullif(trim(to_varchar("INC_JOB_ID")), '') as inc_job_id,
    nullif(trim(to_varchar("FILE_NAME")), '') as file_name,
    nullif(trim(to_varchar("FILE_TIMESTAMP")), '') as file_timestamp,
    nullif(trim(to_varchar("ADDITIONAL_PARTY_LIST")), '') as additional_party_list,
    nullif(trim(to_varchar("BUILDING_DETAILS")), '') as building_details,
    nullif(trim(to_varchar("PARTY_DETAILS")), '') as party_details,
    nullif(trim(to_varchar("POLICY_PROPERTY")), '') as policy_property,
    nullif(trim(to_varchar("POL_PROP_PROP_LIST")), '') as pol_prop_prop_list,
    nullif(trim(to_varchar("RISK_LIST")), '') as risk_list,
    nullif(trim(to_varchar("AGENT_CODE")), '') as agent_code,
    nullif(trim(to_varchar("APPLICATION_CODE")), '') as application_code,
    nullif(trim(to_varchar("BASE_CURRENCY")), '') as base_currency,
    nullif(trim(to_varchar("BASE_CURRENCY_RATE")), '') as base_currency_rate,
    nullif(trim(to_varchar("BILLING_STAKE")), '') as billing_stake,
    nullif(trim(to_varchar("CALCULATE_PREMIUM_INDICATOR")), '') as calculate_premium_indicator,
    nullif(trim(to_varchar("COMMISSION")), '') as commission,
    nullif(trim(to_varchar("DOCUMENT_ID")), '') as document_id,
    nullif(trim(to_varchar("INTIMATION_DATE")), '') as intimation_date,
    nullif(trim(to_varchar("MULTITHREAD_INDICATOR")), '') as multithread_indicator,
    nullif(trim(to_varchar("NEW_PREM_INDICATOR")), '') as new_prem_indicator,
    nullif(trim(to_varchar("PARTY_CODES_FOR_REMOVAL")), '') as party_codes_for_removal,
    nullif(trim(to_varchar("POLICY_BRANCH_NAME")), '') as policy_branch_name,
    nullif(trim(to_varchar("POLICY_DETAILS_CHANGE_INDICATOR")), '') as policy_details_change_indicator,
    nullif(trim(to_varchar("POLICY_EXPIRY_DATE")), '') as policy_expiry_date,
    nullif(trim(to_varchar("POLICY_HOLDER_CODE")), '') as policy_holder_code,
    nullif(trim(to_varchar("POLICY_INCEPTION_DATE")), '') as policy_inception_date,
    nullif(trim(to_varchar("POLICY_QUOTE_NUMBER")), '') as policy_quote_number,
    nullif(trim(to_varchar("POLICY_STATUS_CODE")), '') as policy_status_code,
    nullif(trim(to_varchar("POLICY_TERM")), '') as policy_term,
    nullif(trim(to_varchar("POLICY_TERM_UNIT")), '') as policy_term_unit,
    nullif(trim(to_varchar("PREMIUM_CURRENCY")), '') as premium_currency,
    nullif(trim(to_varchar("PREMIUM_CURRENCY_RATE")), '') as premium_currency_rate,
    nullif(trim(to_varchar("PREMIUM_FREQUENCY")), '') as premium_frequency,
    nullif(trim(to_varchar("PREMIUM_MODE")), '') as premium_mode,
    nullif(trim(to_varchar("STRPRIVILEGE_CODE")), '') as strprivilege_code,
    nullif(trim(to_varchar("PRODUCT_CODE")), '') as product_code,
    nullif(trim(to_varchar("REFER_INDICATOR")), '') as refer_indicator,
    nullif(trim(to_varchar("RET_CODE")), '') as ret_code,
    nullif(trim(to_varchar("RET_ERROR")), '') as ret_error,
    nullif(trim(to_varchar("RISK_ID_FOR_REMOVAL")), '') as risk_id_for_removal,
    nullif(trim(to_varchar("TOTAL_DISCOUNT_AMOUNT")), '') as total_discount_amount,
    nullif(trim(to_varchar("TOTAL_LOADING_AMOUNT")), '') as total_loading_amount,
    nullif(trim(to_varchar("UPDATE_PARTY_INDICATOR")), '') as update_party_indicator,
    nullif(trim(to_varchar("QUOTE_PARAM_DETAILS")), '') as quote_param_details,
    nullif(trim(to_varchar("REC_REFRESH_AT")), '') as rec_refresh_at,
    nullif(trim(to_varchar("REC_REFRESHED_BY")), '') as rec_refreshed_by
    from {{ source('maximus_travel_raw', 'NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS') }}

)

select * from source
