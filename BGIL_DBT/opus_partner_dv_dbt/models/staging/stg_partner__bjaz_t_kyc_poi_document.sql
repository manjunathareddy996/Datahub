{{ config(materialized='view') }}

-- Staging model for source table BJAZ_T_KYC_POI_DOCUMENT (Partner + KYC scope).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP ->
-- TIMESTAMP_NTZ. Key columns (hub-key components) -> canonical trimmed VARCHAR
-- regardless of native type, for stable hashing -- the baseline's own convention.
--
-- CLOB COLUMNS (3): DOC_BYTE_CODE, REQUEST_CLOB, RESPONSE_CLOB.
-- BD-05 / DEC-10: these carry document bytes / request / response payloads. They are
-- available HERE ONLY. They are excluded from every satellite payload and from every
-- hashdiff column list -- hashing them would make change detection thrash on every
-- reload. Each is accompanied by a <col>_present flag and a <col>_digest computed
-- with the sha2 function and deliberately NOT with the md5 one, so that DEC-03's
-- assertion of zero md5 calls in generated SQL stays able to tell a translated key
-- from a CLOB digest (BDEC-04).

with source as (

    select
    "POI_DOC_ID"::number as poi_doc_id,
    nullif(trim("DOCS_TYPE"::varchar), '') as docs_type,
    nullif(trim("DOCS_NUMBER"::varchar), '') as docs_number,
    "DOC_BYTE_CODE"::varchar as doc_byte_code,
    case when "DOC_BYTE_CODE" is not null and length("DOC_BYTE_CODE") > 0 then 'Y' else 'N' end as doc_byte_code_present,
    sha2("DOC_BYTE_CODE"::varchar) as doc_byte_code_digest,
    nullif(trim("DOC_EXTENSION"::varchar), '') as doc_extension,
    nullif(trim("STATUS"::varchar), '') as status,
    nullif(trim("EXPIRY_DATE"::varchar), '') as expiry_date,
    nullif(trim("RESPONSE_CODE"::varchar), '') as response_code,
    nullif(trim("RESPONSE_MESSAGE"::varchar), '') as response_message,
    "REQUEST_CLOB"::varchar as request_clob,
    case when "REQUEST_CLOB" is not null and length("REQUEST_CLOB") > 0 then 'Y' else 'N' end as request_clob_present,
    sha2("REQUEST_CLOB"::varchar) as request_clob_digest,
    "RESPONSE_CLOB"::varchar as response_clob,
    case when "RESPONSE_CLOB" is not null and length("RESPONSE_CLOB") > 0 then 'Y' else 'N' end as response_clob_present,
    sha2("RESPONSE_CLOB"::varchar) as response_clob_digest,
    "CREATED_DATE"::timestamp_ntz as created_date,
    "MODIFY_DATE"::timestamp_ntz as modify_date,
    nullif(trim("FIELD_TYPE"::varchar), '') as field_type,
    nullif(trim("FIELD_VALUE"::varchar), '') as field_value,
    nullif(trim("DOCUMENT_CATEGORY"::varchar), '') as document_category,
    nullif(trim("OMNI_DOC_INDEX"::varchar), '') as omni_doc_index,
    nullif(trim("DOC_NAME"::varchar), '') as doc_name,
    nullif(trim("BUSINESS_UNIT"::varchar), '') as business_unit,
    "OCR_ID"::number as ocr_id,
    nullif(trim("BUSINESS_TYPE"::varchar), '') as business_type,
    nullif(trim("AWS_SERVICE"::varchar), '') as aws_service,
    cast(null as number) as auth_id,  -- AUTH_ID not present in source table
    "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('partner_test_raw', 'BJAZ_T_KYC_POI_DOCUMENT') }}

)

select * from source
