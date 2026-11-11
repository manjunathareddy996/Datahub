-- Staging for source view MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_LIST_OF_COVERS_ENTITY_HEADS_ENTITY_GRID_ROWS_ROW_ATTRIBUTES_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW. Every column trimmed varchar, including the shred keys
-- KEY_HASH / PARENT_KEY_HASH / FOREIGN_KEY that the central views join on.
with source as (

    select
        nullif(trim(to_varchar("FOREIGN_KEY")), '') as foreign_key,
        nullif(trim(to_varchar("PARENT_RECORD_HASH")), '') as parent_record_hash,
        nullif(trim(to_varchar("PARENT_KEY_HASH")), '') as parent_key_hash,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("INC_JOB_CREATED_AT")), '') as inc_job_created_at,
        nullif(trim(to_varchar("REC_REFRESH_AT")), '') as rec_refresh_at,
        nullif(trim(to_varchar("ITEM_COST")), '') as item_cost,
        nullif(trim(to_varchar("ITEM_NAME")), '') as item_name
    from {{ source('maximus_raw', 'MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_LIST_OF_COVERS_ENTITY_HEADS_ENTITY_GRID_ROWS_ROW_ATTRIBUTES_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW') }}

)

select * from source
