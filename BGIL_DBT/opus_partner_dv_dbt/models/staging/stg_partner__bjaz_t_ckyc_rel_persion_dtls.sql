{{ config(materialized='view') }}

-- Staging model for source table BJAZ_T_CKYC_REL_PERSION_DTLS (Partner + KYC scope).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP ->
-- TIMESTAMP_NTZ. Key columns (hub-key components) -> canonical trimmed VARCHAR
-- regardless of native type, for stable hashing -- the baseline's own convention.

with source as (

    select
    "CKYC_REL_PERSON_DTLS_ID"::number as ckyc_rel_person_dtls_id,
    "CKYC_DOWNLOAD_ID"::number as ckyc_download_id,
    nullif(trim("SEQUENCE_NO"::varchar), '') as sequence_no,
    nullif(trim("REL_TYPE"::varchar), '') as rel_type,
    nullif(trim("ADD_DEL_FLAG"::varchar), '') as add_del_flag,
    nullif(trim("CKYC_NO"::varchar), '') as ckyc_no,
    nullif(trim("PREFIX"::varchar), '') as prefix,
    nullif(trim("FNAME"::varchar), '') as fname,
    nullif(trim("MNAME"::varchar), '') as mname,
    nullif(trim("LNAME"::varchar), '') as lname,
    nullif(trim("PAN"::varchar), '') as pan,
    nullif(trim("UID"::varchar), '') as uid,
    nullif(trim("VOTERID"::varchar), '') as voterid,
    nullif(trim("NREGA"::varchar), '') as nrega,
    nullif(trim("PASSPORT"::varchar), '') as passport,
    nullif(trim("DRIVING_LICENCE"::varchar), '') as driving_licence,
    nullif(trim("OTHERID_NAME"::varchar), '') as otherid_name,
    nullif(trim("OTHERID_NO"::varchar), '') as otherid_no,
    nullif(trim("SIMPLIFIED_CODE"::varchar), '') as simplified_code,
    nullif(trim("SIMPLIFIED_NO"::varchar), '') as simplified_no,
    nullif(trim("DEC_DATE"::varchar), '') as dec_date,
    nullif(trim("DEC_PLACE"::varchar), '') as dec_place,
    "DIN"::number as din,
    nullif(trim("RE_TYPE_OTHERS_DESC"::varchar), '') as re_type_others_desc,
    "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('partner_test_raw', 'BJAZ_T_CKYC_REL_PERSION_DTLS') }}

)

select * from source
