-- Staging for source view MAXI_HLTH_UWR_VW_DATA_VIEW_COLLECTIONS_ADDITIONAL_DETAILS_PIVOT_VW. Every column trimmed varchar, including the shred keys
-- KEY_HASH / PARENT_KEY_HASH / FOREIGN_KEY that the central views join on.
with source as (

    select
        nullif(trim(to_varchar("FOREIGN_KEY")), '') as foreign_key,
        nullif(trim(to_varchar("PARENT_RECORD_HASH")), '') as parent_record_hash,
        nullif(trim(to_varchar("PARENT_KEY_HASH")), '') as parent_key_hash,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("INC_JOB_CREATED_AT")), '') as inc_job_created_at,
        nullif(trim(to_varchar("REC_REFRESH_AT")), '') as rec_refresh_at,
        nullif(trim(to_varchar("ACTION_BY")), '') as action_by,
        nullif(trim(to_varchar("ACTION_DATE")), '') as action_date,
        nullif(trim(to_varchar("ACTION_ON_CHEQUE")), '') as action_on_cheque,
        nullif(trim(to_varchar("CARD_EXPIRY_DATE")), '') as card_expiry_date,
        nullif(trim(to_varchar("CARD_NUMBERLAST_4_DIGITS")), '') as card_numberlast_4_digits,
        nullif(trim(to_varchar("CARD_TRANS_DATE")), '') as card_trans_date,
        nullif(trim(to_varchar("CARD_TRANS_NO")), '') as card_trans_no,
        nullif(trim(to_varchar("CARD_TYPE")), '') as card_type,
        nullif(trim(to_varchar("CHEQUE_ISSUED_BY_NAME")), '') as cheque_issued_by_name,
        nullif(trim(to_varchar("CHILD_POLICY")), '') as child_policy,
        nullif(trim(to_varchar("CITY_NAME")), '') as city_name,
        nullif(trim(to_varchar("DISHONOUR_ID")), '') as dishonour_id,
        nullif(trim(to_varchar("DISHONOUR_REASON")), '') as dishonour_reason,
        nullif(trim(to_varchar("EXCESS")), '') as excess,
        nullif(trim(to_varchar("IFSC_CODE")), '') as ifsc_code,
        nullif(trim(to_varchar("ISSUING_BANK")), '') as issuing_bank,
        nullif(trim(to_varchar("MICR_CODE")), '') as micr_code,
        nullif(trim(to_varchar("MINIMUM_PREMIUM_TO_BE_COLLECTED")), '') as minimum_premium_to_be_collected,
        nullif(trim(to_varchar("MOBILE_NUMBER")), '') as mobile_number,
        nullif(trim(to_varchar("PAYER_BANK_ACCOUNT_NO")), '') as payer_bank_account_no,
        nullif(trim(to_varchar("PGIREFNO")), '') as pgirefno,
        nullif(trim(to_varchar("REALISATION_DATE")), '') as realisation_date,
        nullif(trim(to_varchar("RECEIPT_STATUS")), '') as receipt_status,
        nullif(trim(to_varchar("RECEIVED_DATE")), '') as received_date,
        nullif(trim(to_varchar("REVERSE_ID")), '') as reverse_id,
        nullif(trim(to_varchar("REVERSE_REASON")), '') as reverse_reason
    from {{ source('maximus_raw', 'MAXI_HLTH_UWR_VW_DATA_VIEW_COLLECTIONS_ADDITIONAL_DETAILS_PIVOT_VW') }}

)

select * from source
