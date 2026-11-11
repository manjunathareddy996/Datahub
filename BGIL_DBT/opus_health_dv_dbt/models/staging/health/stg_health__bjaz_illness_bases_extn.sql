-- Staging for source table BJAZ_ILLNESS_BASES_EXTN (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("ANNUAL_INCOME")), '') as annual_income,
        nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
        nullif(trim(to_varchar("COVERNOTE_DATE")), '') as covernote_date,
        nullif(trim(to_varchar("COVERNOTE_NO")), '') as covernote_no,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at,
        nullif(trim(to_varchar("MEDICAL_EXPENSES")), '') as medical_expenses,
        nullif(trim(to_varchar("NOMINEE_NAME")), '') as nominee_name,
        nullif(trim(to_varchar("NOMINEE_RELATION")), '') as nominee_relation,
        nullif(trim(to_varchar("RELATION")), '') as relation,
        nullif(trim(to_varchar("SPECIAL_CONDITION")), '') as special_condition,
        nullif(trim(to_varchar("SUM_INSURED")), '') as sum_insured
    from {{ source('health_raw', 'BJAZ_ILLNESS_BASES_EXTN') }}

)

select * from source
