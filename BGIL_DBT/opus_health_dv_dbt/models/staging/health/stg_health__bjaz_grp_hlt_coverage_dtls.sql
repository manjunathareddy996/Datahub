-- Staging for source table BJAZ_GRP_HLT_COVERAGE_DTLS (run opus_health_delta3). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("maternity_benefit")), '') as maternity_benefit,
        nullif(trim(to_varchar("one_waiting_period")), '') as one_waiting_period,
        nullif(trim(to_varchar("pre_existing_dis")), '') as pre_existing_dis,
        nullif(trim(to_varchar("product")), '') as product,
        nullif(trim(to_varchar("quote_no")), '') as quote_no,
        nullif(trim(to_varchar("quote_sub_no")), '') as quote_sub_no,
        nullif(trim(to_varchar("reg_no")), '') as reg_no,
        nullif(trim(to_varchar("thirty_waiting_period")), '') as thirty_waiting_period,
        nullif(trim(to_varchar("top_indicator")), '') as top_indicator,
        nullif(trim(to_varchar("version_no")), '') as version_no
    from {{ source('health_raw', 'BJAZ_GRP_HLT_COVERAGE_DTLS') }}

)

select * from source
