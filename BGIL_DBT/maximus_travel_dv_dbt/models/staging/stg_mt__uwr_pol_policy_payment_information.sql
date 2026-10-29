{{ config(materialized='view') }}

-- Layer-1 cast for Maximus Travel source view
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PAYMENT_INFORMATION
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
    nullif(trim(to_varchar("CHEQUE_NUMBER")), '') as cheque_number,
    nullif(trim(to_varchar("CHEQUE_REALISATION_DATE")), '') as cheque_realisation_date,
    nullif(trim(to_varchar("CHEQUE_STATUS")), '') as cheque_status,
    nullif(trim(to_varchar("COLLECTION_AMOUNT")), '') as collection_amount,
    nullif(trim(to_varchar("COLLECTION_DATE")), '') as collection_date,
    nullif(trim(to_varchar("COLLECTION_MODE")), '') as collection_mode,
    nullif(trim(to_varchar("COLLECTION_SOURCE")), '') as collection_source,
    nullif(trim(to_varchar("COLLECTION_TYPE")), '') as collection_type,
    nullif(trim(to_varchar("RECEIPT_GENERATION_DATE")), '') as receipt_generation_date,
    nullif(trim(to_varchar("RECEIPT_NUMBER")), '') as receipt_number,
    nullif(trim(to_varchar("SUB_CODE")), '') as sub_code,
    nullif(trim(to_varchar("TRANSACTION_DATE")), '') as transaction_date,
    nullif(trim(to_varchar("TRANSACTION_ID")), '') as transaction_id,
    nullif(trim(to_varchar("POLICY_PAYMENT_INFORMATION")), '') as policy_payment_information,
    nullif(trim(to_varchar("REC_REFRESH_AT")), '') as rec_refresh_at,
    nullif(trim(to_varchar("REC_REFRESHED_BY")), '') as rec_refreshed_by
    from {{ source('maximus_travel_raw', 'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PAYMENT_INFORMATION') }}

)

select * from source
