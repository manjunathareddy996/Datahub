-- Staging for source table BJAZ_GRP_HLT_IMD_DTLS (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("IMD_CODE")), '') as imd_code,
        nullif(trim(to_varchar("IMD_NAME")), '') as imd_name,
        nullif(trim(to_varchar("PRODUCT")), '') as product,
        nullif(trim(to_varchar("QUOTE_NO")), '') as quote_no,
        nullif(trim(to_varchar("QUOTE_SUB_NO")), '') as quote_sub_no,
        nullif(trim(to_varchar("REG_NO")), '') as reg_no,
        nullif(trim(to_varchar("RM_CODE")), '') as rm_code,
        nullif(trim(to_varchar("RM_NAME")), '') as rm_name,
        nullif(trim(to_varchar("SUB_IMD_CODE")), '') as sub_imd_code,
        nullif(trim(to_varchar("SUB_IMD_NAME")), '') as sub_imd_name
    from {{ source('health_raw', 'BJAZ_GRP_HLT_IMD_DTLS') }}

)

select * from source
