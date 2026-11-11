-- Staging for source view MAXI_HLTH_UWR_VW_DATA_VIEW_COLLECTIONS. Every column trimmed varchar, including the shred keys
-- KEY_HASH / PARENT_KEY_HASH / FOREIGN_KEY that the central views join on.
with source as (

    select
        nullif(trim(to_varchar("INC_JOB_CREATED_AT")), '') as inc_job_created_at,
        nullif(trim(to_varchar("INC_JOB_ID")), '') as inc_job_id,
        nullif(trim(to_varchar("FILE_NAME")), '') as file_name,
        nullif(trim(to_varchar("FILE_TIMESTAMP")), '') as file_timestamp,
        nullif(trim(to_varchar("FOREIGN_KEY")), '') as foreign_key,
        nullif(trim(to_varchar("ROOT_HASH")), '') as root_hash,
        nullif(trim(to_varchar("PARENT_KEY_HASH")), '') as parent_key_hash,
        nullif(trim(to_varchar("PARENT_RECORD_HASH")), '') as parent_record_hash,
        nullif(trim(to_varchar("ACCOUNT_CODE")), '') as account_code,
        nullif(trim(to_varchar("AMOUNT")), '') as amount,
        nullif(trim(to_varchar("AMOUNT_TO_BE_COLLECTED_PAID")), '') as amount_to_be_collected_paid,
        nullif(trim(to_varchar("CHQ_INS_DATE")), '') as chq_ins_date,
        nullif(trim(to_varchar("CHQ_INS_NUMBER")), '') as chq_ins_number,
        nullif(trim(to_varchar("CHQ_INS_TYPE")), '') as chq_ins_type,
        nullif(trim(to_varchar("COLLECTION_PAYMENT_AMOUNT")), '') as collection_payment_amount,
        nullif(trim(to_varchar("COLLECTION_PAYMENT_NUMBER")), '') as collection_payment_number,
        nullif(trim(to_varchar("COLLECTION_PAYMENT_TYPE")), '') as collection_payment_type,
        nullif(trim(to_varchar("COLLECTION_SUB_TYPE")), '') as collection_sub_type,
        nullif(trim(to_varchar("CREATED_BY")), '') as created_by,
        nullif(trim(to_varchar("CREDIT_ACCOUNT_CODE")), '') as credit_account_code,
        nullif(trim(to_varchar("CURRENCY")), '') as currency,
        nullif(trim(to_varchar("CURRENCY_RATE")), '') as currency_rate,
        nullif(trim(to_varchar("DATE_OF_COLLECTION_PAYMENT")), '') as date_of_collection_payment,
        nullif(trim(to_varchar("DATE_OF_POSTING")), '') as date_of_posting,
        nullif(trim(to_varchar("DRAWEE_BANK_BRANCH")), '') as drawee_bank_branch,
        nullif(trim(to_varchar("DRAWEE_BANK_NAME")), '') as drawee_bank_name,
        nullif(trim(to_varchar("EFFECTIVE_DATE")), '') as effective_date,
        nullif(trim(to_varchar("IMD_CHANNEL")), '') as imd_channel,
        nullif(trim(to_varchar("IMD_CODE")), '') as imd_code,
        nullif(trim(to_varchar("IMD_CODE_NAME")), '') as imd_code_name,
        nullif(trim(to_varchar("MODE")), '') as mode,
        nullif(trim(to_varchar("NARRATION")), '') as narration,
        nullif(trim(to_varchar("OTHER_APPROVED_SRC")), '') as other_approved_src,
        nullif(trim(to_varchar("POLICY_QUOTATION_DEBIT_NOTE_NO")), '') as policy_quotation_debit_note_no,
        nullif(trim(to_varchar("POSTED_BY")), '') as posted_by,
        nullif(trim(to_varchar("RECEIVED_FROM")), '') as received_from,
        nullif(trim(to_varchar("REFERENCE_NO")), '') as reference_no,
        nullif(trim(to_varchar("SCROLL_DATE")), '') as scroll_date,
        nullif(trim(to_varchar("SOURCE_OF_COLLECTION")), '') as source_of_collection,
        nullif(trim(to_varchar("SUB_CODE")), '') as sub_code,
        nullif(trim(to_varchar("SUB_IMD_CHANNEL")), '') as sub_imd_channel,
        nullif(trim(to_varchar("SUB_IMD_CODE")), '') as sub_imd_code,
        nullif(trim(to_varchar("VOUCHER_NUMBER")), '') as voucher_number,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("RECORD_HASH")), '') as record_hash,
        nullif(trim(to_varchar("VIEW_COLLECTIONS")), '') as view_collections,
        nullif(trim(to_varchar("REC_REFRESH_AT")), '') as rec_refresh_at,
        nullif(trim(to_varchar("REC_REFRESHED_BY")), '') as rec_refreshed_by,
        nullif(trim(to_varchar("PARENT_TABLE_NAME")), '') as parent_table_name
    from {{ source('maximus_raw', 'MAXI_HLTH_UWR_VW_DATA_VIEW_COLLECTIONS') }}

)

select * from source
