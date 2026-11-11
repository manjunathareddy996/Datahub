-- Staging for source table BJAZ_BOT_UTILIZATION_DTLS (run opus_health_delta3). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("branch_code")), '') as branch_code,
        nullif(trim(to_varchar("chatbot_id")), '') as chatbot_id,
        nullif(trim(to_varchar("chatbot_name")), '') as chatbot_name,
        nullif(trim(to_varchar("cust_name")), '') as cust_name,
        nullif(trim(to_varchar("date_generated")), '') as date_generated,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at,
        nullif(trim(to_varchar("pincode")), '') as pincode,
        nullif(trim(to_varchar("prev_reference_no")), '') as prev_reference_no,
        nullif(trim(to_varchar("product_code")), '') as product_code,
        nullif(trim(to_varchar("reference_no")), '') as reference_no,
        nullif(trim(to_varchar("request_type")), '') as request_type,
        nullif(trim(to_varchar("service_hit_cnt")), '') as service_hit_cnt,
        nullif(trim(to_varchar("service_name")), '') as service_name,
        nullif(trim(to_varchar("user_name")), '') as user_name
    from {{ source('health_raw', 'BJAZ_BOT_UTILIZATION_DTLS') }}

)

select * from source
