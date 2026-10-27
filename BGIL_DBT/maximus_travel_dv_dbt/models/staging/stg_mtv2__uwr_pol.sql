{{ config(materialized='view') }}

-- Layer-1 cast for Maximus Travel V2 source view
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS
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
    nullif(trim(to_varchar("AGENT_CODE")), '') as agent_code,
    nullif(trim(to_varchar("COMMISION")), '') as commision,
    nullif(trim(to_varchar("DISPATCH_DETAILS")), '') as dispatch_details,
    nullif(trim(to_varchar("DOCUMENT_DETAILS")), '') as document_details,
    nullif(trim(to_varchar("ENDORSEMENT_DETAILS")), '') as endorsement_details,
    nullif(trim(to_varchar("GST")), '') as gst,
    nullif(trim(to_varchar("INSURED_DETAILS")), '') as insured_details,
    nullif(trim(to_varchar("NET_PREMIUM")), '') as net_premium,
    nullif(trim(to_varchar("OFFICE_DETAILS")), '') as office_details,
    nullif(trim(to_varchar("PAYMENT_FREQUENCY")), '') as payment_frequency,
    nullif(trim(to_varchar("POLICY_DURATION")), '') as policy_duration,
    nullif(trim(to_varchar("POLICY_DURATIONUNIT")), '') as policy_durationunit,
    nullif(trim(to_varchar("POLICY_EXPIRY_DATE")), '') as policy_expiry_date,
    nullif(trim(to_varchar("POLICY_HOLDER_CODE")), '') as policy_holder_code,
    nullif(trim(to_varchar("POLICY_INCEPTION_DATE")), '') as policy_inception_date,
    nullif(trim(to_varchar("POLICY_NUMBER")), '') as policy_number,
    nullif(trim(to_varchar("POLICY_PAYMENT_INFORMATION")), '') as policy_payment_information,
    nullif(trim(to_varchar("POLICY_PROPERTY")), '') as policy_property,
    nullif(trim(to_varchar("POLICY_RELATION")), '') as policy_relation,
    nullif(trim(to_varchar("POLICY_STATUS")), '') as policy_status,
    nullif(trim(to_varchar("PREMIUM_MODE")), '') as premium_mode,
    nullif(trim(to_varchar("PREVIOUS_POLICY_DETAILS")), '') as previous_policy_details,
    nullif(trim(to_varchar("PRODUCT_CODE")), '') as product_code,
    nullif(trim(to_varchar("PRODUCT_NAME")), '') as product_name,
    nullif(trim(to_varchar("PROPOSER_DETAILS")), '') as proposer_details,
    nullif(trim(to_varchar("QUOTATION_NUMBER")), '') as quotation_number,
    nullif(trim(to_varchar("RENEWAL_FLAG")), '') as renewal_flag,
    nullif(trim(to_varchar("STAMP_DUTY")), '') as stamp_duty,
    nullif(trim(to_varchar("POLICY_BRANCH_NAME")), '') as policy_branch_name,
    nullif(trim(to_varchar("POLICY_INTIMATION_DATE")), '') as policy_intimation_date,
    nullif(trim(to_varchar("TELE_VERIFICATION_DETAILS")), '') as tele_verification_details,
    nullif(trim(to_varchar("TOTAL_PREMIUM")), '') as total_premium,
    nullif(trim(to_varchar("WORK_ITEM_DETAILS")), '') as work_item_details,
    nullif(trim(to_varchar("POLICY_DETAILS")), '') as policy_details,
    nullif(trim(to_varchar("REC_REFRESH_AT")), '') as rec_refresh_at,
    nullif(trim(to_varchar("REC_REFRESHED_BY")), '') as rec_refreshed_by
    from {{ source('maximus_travel_v2_raw', 'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS') }}

)

select * from source
