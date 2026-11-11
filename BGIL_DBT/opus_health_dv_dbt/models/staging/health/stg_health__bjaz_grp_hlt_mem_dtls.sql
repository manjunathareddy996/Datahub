-- Staging for source table BJAZ_GRP_HLT_MEM_DTLS (run opus_health_delta3). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("AGE_RESTRICTION")), '') as age_restriction,
        nullif(trim(to_varchar("COUNT")), '') as count,
        nullif(trim(to_varchar("COVERAGE")), '') as coverage,
        nullif(trim(to_varchar("MEMBER")), '') as member,
        nullif(trim(to_varchar("PRODUCT")), '') as product,
        nullif(trim(to_varchar("QUOTE_NO")), '') as quote_no,
        nullif(trim(to_varchar("QUOTE_SUB_NO")), '') as quote_sub_no,
        nullif(trim(to_varchar("REG_NO")), '') as reg_no,
        nullif(trim(to_varchar("TOP_INDICATOR")), '') as top_indicator,
        nullif(trim(to_varchar("VERSION_NO")), '') as version_no
    from {{ source('health_raw', 'BJAZ_GRP_HLT_MEM_DTLS') }}

)

select * from source
