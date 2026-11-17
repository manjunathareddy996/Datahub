-- Staging for source table BJAZ_MOT_CLM_TRANS_EXTN. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
        nullif(trim(to_varchar("SF_NO")), '') as sf_no,
        nullif(trim(to_varchar("TRANS_NO")), '') as trans_no,
        nullif(trim(to_varchar("PAYMENT_MODE")), '') as payment_mode,
        nullif(trim(to_varchar("REQUEST_ID")), '') as request_id,
        nullif(trim(to_varchar("BANK_CODE")), '') as bank_code,
        nullif(trim(to_varchar("BANK_BRANCH_CODE")), '') as bank_branch_code,
        nullif(trim(to_varchar("PAYMENT_DUE_DATE")), '') as payment_due_date,
        nullif(trim(to_varchar("DAMAGED_OBJECT")), '') as damaged_object,
        nullif(trim(to_varchar("DAMAGE_TYPE")), '') as damage_type,
        nullif(trim(to_varchar("AVAILABLE_RSV_AMT")), '') as available_rsv_amt,
        nullif(trim(to_varchar("PAYEE_IP_NO")), '') as payee_ip_no,
        nullif(trim(to_varchar("ADD_TYPE")), '') as add_type,
        nullif(trim(to_varchar("SERVICE_TAX_AMT")), '') as service_tax_amt,
        nullif(trim(to_varchar("REFERENCE_TEXT")), '') as reference_text,
        nullif(trim(to_varchar("FOREIGN_CURR_FLAG")), '') as foreign_curr_flag,
        nullif(trim(to_varchar("REINS_PREMIUM")), '') as reins_premium,
        nullif(trim(to_varchar("COINS_RECOVERY_AMT")), '') as coins_recovery_amt,
        nullif(trim(to_varchar("TYPE_OF_RECOVERY")), '') as type_of_recovery,
        nullif(trim(to_varchar("RECOVERY_AMT")), '') as recovery_amt,
        nullif(trim(to_varchar("TYPE_OF_SALVAGE")), '') as type_of_salvage,
        nullif(trim(to_varchar("SALVAGE_AMT")), '') as salvage_amt,
        nullif(trim(to_varchar("INTEREST_PERC")), '') as interest_perc,
        nullif(trim(to_varchar("INTEREST_AMT")), '') as interest_amt,
        nullif(trim(to_varchar("EXCHANGE_RATE")), '') as exchange_rate,
        nullif(trim(to_varchar("EXCHANGE_GAIN_AMT")), '') as exchange_gain_amt,
        nullif(trim(to_varchar("EXCHANGE_RATE_CURR")), '') as exchange_rate_curr,
        nullif(trim(to_varchar("USER_NAME")), '') as user_name,
        nullif(trim(to_varchar("EVENT_CODE")), '') as event_code,
        nullif(trim(to_varchar("PAY_LOCAL")), '') as pay_local,
        nullif(trim(to_varchar("PAY_LOCATION")), '') as pay_location,
        nullif(trim(to_varchar("REASON_FOR_CHQ")), '') as reason_for_chq,
        nullif(trim(to_varchar("NCB_RECOVERY_AMT")), '') as ncb_recovery_amt,
        nullif(trim(to_varchar("INVOICE_DATE")), '') as invoice_date,
        nullif(trim(to_varchar("GSTN_NO")), '') as gstn_no,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_raw', 'BJAZ_MOT_CLM_TRANS_EXTN') }}

)

select * from source
