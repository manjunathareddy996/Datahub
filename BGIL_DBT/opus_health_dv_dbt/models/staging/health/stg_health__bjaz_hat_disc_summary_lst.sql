-- Staging for source table BJAZ_HAT_DISC_SUMMARY_LST (run opus_health_v2). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("DISC_AMOUNT")), '') as disc_amount,
        nullif(trim(to_varchar("DISC_BILL_DATE")), '') as disc_bill_date,
        nullif(trim(to_varchar("DISC_BILL_NUMBER")), '') as disc_bill_number,
        nullif(trim(to_varchar("DISC_CASE_ID")), '') as disc_case_id,
        nullif(trim(to_varchar("DISC_PARTICULAR_LEAD_TERM")), '') as disc_particular_lead_term,
        nullif(trim(to_varchar("DISC_PARTICULAR_PROFILE_TERM")), '') as disc_particular_profile_term,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at,
        nullif(trim(to_varchar("DISC_PARTICULAR_RAW")), '') as disc_particular_raw
    from {{ source('health_raw', 'BJAZ_HAT_DISC_SUMMARY_LST') }}

)

select * from source
