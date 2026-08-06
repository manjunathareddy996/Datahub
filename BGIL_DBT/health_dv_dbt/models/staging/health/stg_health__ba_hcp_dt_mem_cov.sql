-- Staging model for source table BA_HCP_DT_MEM_COV (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
    nullif(trim(to_varchar("HCP_SEQNO")), '') as hcp_seqno,
    nullif(trim("MEMBER_NAME"::varchar), '') as member_name,
    nullif(trim("MEM_ADD_FLAG"::varchar), '') as mem_add_flag,
    nullif(trim(to_varchar("MEM_SEQNO")), '') as mem_seqno,
    nullif(trim("MEM_STATUS"::varchar), '') as mem_status,
    nullif(trim(to_varchar("PART_ID")), '') as part_id
    from {{ source('health_raw', 'BA_HCP_DT_MEM_COV') }}

)

select * from source
