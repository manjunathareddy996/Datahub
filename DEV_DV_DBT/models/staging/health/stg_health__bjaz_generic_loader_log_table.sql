-- Staging model for source table BJAZ_GENERIC_LOADER_LOG_TABLE (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim("AADHAR_VALID_STATUS"::varchar), '') as aadhar_valid_status,
    nullif(trim("AGE"::varchar), '') as age,
    nullif(trim("BUILDING"::varchar), '') as building,
    nullif(trim("CITY"::varchar), '') as city,
    nullif(trim("COMPANYNAME"::varchar), '') as companyname,
    nullif(trim("COUNTRY"::varchar), '') as country,
    nullif(trim("DATEOFBIRTH"::varchar), '') as dateofbirth,
    nullif(trim("EMAIL"::varchar), '') as email,
    nullif(trim("EMPNO"::varchar), '') as empno,
    nullif(trim("EMPSTATUS"::varchar), '') as empstatus,
    nullif(trim("FAX"::varchar), '') as fax,
    nullif(trim("FIRSTNAME"::varchar), '') as firstname,
    nullif(trim("INTERMEDIARY"::varchar), '') as intermediary,
    nullif(trim(to_varchar("LOCATIONCODE")), '') as locationcode,
    nullif(trim("MARITALSTATUS"::varchar), '') as maritalstatus,
    nullif(trim("MIDDLENAME"::varchar), '') as middlename,
    nullif(trim("MOBILENUMBER"::varchar), '') as mobilenumber,
    nullif(trim("PAN_VALID_STATUS"::varchar), '') as pan_valid_status,
    nullif(trim(to_varchar("PARTNERID")), '') as partnerid,
    nullif(trim("PASSPORTNO"::varchar), '') as passportno,
    nullif(trim("PAYMENTMODE"::varchar), '') as paymentmode,
    nullif(trim(to_varchar("PCONTRACTID")), '') as pcontractid,
    nullif(trim("PGROSSPREMIUM"::varchar), '') as pgrosspremium,
    nullif(trim("PINCODE"::varchar), '') as pincode,
    nullif(trim(to_varchar("PLANID")), '') as planid,
    nullif(trim(to_varchar("PMASTERPOLICYNUMBER")), '') as pmasterpolicynumber,
    nullif(trim("POLICYISSUEDATE"::varchar), '') as policyissuedate,
    nullif(trim(to_varchar("POLICYNUMBER")), '') as policynumber,
    nullif(trim("PREMIUMPAYERID"::varchar), '') as premiumpayerid,
    nullif(trim("PSERVICETAX"::varchar), '') as pservicetax,
    nullif(trim("PSTARTDATE"::varchar), '') as pstartdate,
    nullif(trim("PTODATE"::varchar), '') as ptodate,
    nullif(trim("PTOTALPREMIUM"::varchar), '') as ptotalpremium,
    nullif(trim(to_varchar("SCHEMECODE")), '') as schemecode,
    nullif(trim("SEX"::varchar), '') as sex,
    nullif(trim("STATE"::varchar), '') as state,
    nullif(trim("STREETNAME"::varchar), '') as streetname,
    nullif(trim("SUM_INSURED"::varchar), '') as sum_insured,
    nullif(trim("SURNAME"::varchar), '') as surname,
    nullif(trim("TELEPHONE"::varchar), '') as telephone,
    nullif(trim("TITLE"::varchar), '') as title
    from {{ source('health_raw', 'BJAZ_GENERIC_LOADER_LOG_TABLE') }}

)

select * from source
