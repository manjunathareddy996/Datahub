{{ config(materialized='view') }}

-- Layer-1 cast for Maximus Travel V2 source view
--   NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST
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
    nullif(trim(to_varchar("ADDITIONAL_PARTY_CODE")), '') as additional_party_code,
    nullif(trim(to_varchar("BASE_CURRENCY")), '') as base_currency,
    nullif(trim(to_varchar("MULTI_SET_PROPERTY_INPUT")), '') as multi_set_property_input,
    nullif(trim(to_varchar("PARTY_DETAILS")), '') as party_details,
    nullif(trim(to_varchar("PREM_CURRENCY")), '') as prem_currency,
    nullif(trim(to_varchar("RISK_COVER")), '') as risk_cover,
    nullif(trim(to_varchar("RISK_PROPERTY")), '') as risk_property,
    nullif(trim(to_varchar("ADDR1")), '') as addr1,
    nullif(trim(to_varchar("ADDR2")), '') as addr2,
    nullif(trim(to_varchar("ADDR3")), '') as addr3,
    nullif(trim(to_varchar("BILLING_STAKE")), '') as billing_stake,
    nullif(trim(to_varchar("CITY_CODE")), '') as city_code,
    nullif(trim(to_varchar("COUNTRY_CODE")), '') as country_code,
    nullif(trim(to_varchar("DISCOUNT")), '') as discount,
    nullif(trim(to_varchar("DOCUMENT_ID")), '') as document_id,
    nullif(trim(to_varchar("LOADING")), '') as loading,
    nullif(trim(to_varchar("PARTY_CODE")), '') as party_code,
    nullif(trim(to_varchar("POLICY_COUNTRY")), '') as policy_country,
    nullif(trim(to_varchar("POLICY_ID")), '') as policy_id,
    nullif(trim(to_varchar("POL_RISK_ID")), '') as pol_risk_id,
    nullif(trim(to_varchar("POSTAL_CODE")), '') as postal_code,
    nullif(trim(to_varchar("RISK_CODE")), '') as risk_code,
    nullif(trim(to_varchar("RISK_DESC")), '') as risk_desc,
    nullif(trim(to_varchar("RISK_EXPIRY_DATE")), '') as risk_expiry_date,
    nullif(trim(to_varchar("RISK_INCEPTION_DATE")), '') as risk_inception_date,
    nullif(trim(to_varchar("RISK_SERIAL_NUMBER")), '') as risk_serial_number,
    nullif(trim(to_varchar("RISK_SUM_INSURED")), '') as risk_sum_insured,
    nullif(trim(to_varchar("STATE_CODE")), '') as state_code,
    nullif(trim(to_varchar("RISK_LIST")), '') as risk_list,
    nullif(trim(to_varchar("REC_REFRESH_AT")), '') as rec_refresh_at,
    nullif(trim(to_varchar("REC_REFRESHED_BY")), '') as rec_refreshed_by
    from {{ source('maximus_travel_v2_raw', 'NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST') }}

)

select * from source
