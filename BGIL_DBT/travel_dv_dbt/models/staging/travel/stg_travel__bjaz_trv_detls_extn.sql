-- Staging model for source table BJAZ_TRV_DETLS_EXTN (Travel LOB).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, TIMESTAMP/DATE -> TIMESTAMP_NTZ.
-- Key columns (hub-key components) -> canonical trimmed VARCHAR regardless of native type,
-- for stable hashing -- same convention as the Health/Partner LOB builds.
-- Types read from OPUS_TRAVEL_SCHEMA_with_DATA_TYPE.csv (real Snowflake DESCRIBE-style
-- metadata, supplied by the mapper) -- not inferred.

with source as (

    select
    nullif(trim(to_varchar("ACTION_CODE")), '') as action_code,
    nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
    nullif(trim(to_varchar("COST_CENTER")), '') as cost_center,
    "COVERNOTE_DATE"::timestamp_ntz as covernote_date,
    "COVERNOTE_NO"::number as covernote_no,
    "DEPARTURE_DATE"::timestamp_ntz as departure_date,
    nullif(trim(to_varchar("GEO_AREA")), '') as geo_area,
    nullif(trim(to_varchar("MARKETING_AGENT")), '') as marketing_agent,
    "RETURN_DATE"::timestamp_ntz as return_date,
    nullif(trim(to_varchar("SPECIAL_CONDITION")), '') as special_condition,
    nullif(trim(to_varchar("TRAVEL_REQ_NO")), '') as travel_req_no,
    "TRP_DLY_PRM"::number as trp_dly_prm,
    nullif(trim(to_varchar("TRP_DLY_WAY")), '') as trp_dly_way,
    nullif(trim(to_varchar("TRP_DLY_YN")), '') as trp_dly_yn,
    nullif(trim(to_varchar("TRV_PLAN")), '') as trv_plan
    from {{ source('travel_raw', 'BJAZ_TRV_DETLS_EXTN') }}

)

select * from source
