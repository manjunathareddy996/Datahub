-- Staging for source table BA_HCP_DT_MEM_COV (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
        nullif(trim(to_varchar("HCP_SEQNO")), '') as hcp_seqno,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at,
        nullif(trim(to_varchar("MEMBER_NAME")), '') as member_name,
        nullif(trim(to_varchar("MEM_ADD_FLAG")), '') as mem_add_flag,
        nullif(trim(to_varchar("MEM_SEQNO")), '') as mem_seqno,
        nullif(trim(to_varchar("MEM_STATUS")), '') as mem_status,
        nullif(trim(to_varchar("PART_ID")), '') as part_id,
        nullif(trim(to_varchar("PREM_BASE_COVER")), '') as prem_base_cover
    from {{ source('health_raw', 'BA_HCP_DT_MEM_COV') }}

)

select * from source
