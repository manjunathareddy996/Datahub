{{ config(materialized='view') }}

-- Layer-1 cast for Maximus Travel source view
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
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
    nullif(trim(to_varchar("ACCOUNT_TYPE")), '') as account_type,
    nullif(trim(to_varchar("APPROVEDREJECTED_BY")), '') as approvedrejected_by,
    nullif(trim(to_varchar("APPROVEDREJECTED_DATE")), '') as approvedrejected_date,
    nullif(trim(to_varchar("BANK_ACCOUNT_NUMBER")), '') as bank_account_number,
    nullif(trim(to_varchar("BANK_BRANCH_NAME")), '') as bank_branch_name,
    nullif(trim(to_varchar("CONFIRM_BANK_ACCOUNT_NUMBER")), '') as confirm_bank_account_number,
    nullif(trim(to_varchar("IFSC")), '') as ifsc,
    nullif(trim(to_varchar("MICR")), '') as micr,
    nullif(trim(to_varchar("NAME_AS_PER_BANK_AC")), '') as name_as_per_bank_ac,
    nullif(trim(to_varchar("NAME_OF_THE_BANK")), '') as name_of_the_bank,
    nullif(trim(to_varchar("NEFT_STATUS")), '') as neft_status,
    nullif(trim(to_varchar("PASSPORT_EXPIRY_DATE")), '') as passport_expiry_date,
    nullif(trim(to_varchar("PASSPORT_FILE_NO")), '') as passport_file_no,
    nullif(trim(to_varchar("PASSPORT_ISSUE_COUNTRY")), '') as passport_issue_country,
    nullif(trim(to_varchar("PASSPORT_ISSUE_DATE")), '') as passport_issue_date,
    nullif(trim(to_varchar("PASSPORT_NUMBER")), '') as passport_number,
    nullif(trim(to_varchar("PAYEE_NAME_AS_PER_BANK_RECORD")), '') as payee_name_as_per_bank_record,
    nullif(trim(to_varchar("PENNYDROPLESS_FLAG")), '') as pennydropless_flag,
    nullif(trim(to_varchar("PENNY_SCORE")), '') as penny_score,
    nullif(trim(to_varchar("PRIMARY_SECONDARY")), '') as primary_secondary,
    nullif(trim(to_varchar("REMARKS")), '') as remarks
    from {{ source('maximus_travel_raw', 'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW') }}

)

select * from source
