-- Staging for source table BJAZ_GENERIC_LOADER_LOG_TABLE (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("AADHAR_VALID_STATUS")), '') as aadhar_valid_status,
        nullif(trim(to_varchar("AGE")), '') as age,
        nullif(trim(to_varchar("ASSIGNEE")), '') as assignee,
        nullif(trim(to_varchar("BUILDING")), '') as building,
        nullif(trim(to_varchar("CITY")), '') as city,
        nullif(trim(to_varchar("COMPANYNAME")), '') as companyname,
        nullif(trim(to_varchar("COUNTRY")), '') as country,
        nullif(trim(to_varchar("DATEOFBIRTH")), '') as dateofbirth,
        nullif(trim(to_varchar("EMAIL")), '') as email,
        nullif(trim(to_varchar("EMPNO")), '') as empno,
        nullif(trim(to_varchar("EMPSTATUS")), '') as empstatus,
        nullif(trim(to_varchar("FAX")), '') as fax,
        nullif(trim(to_varchar("FIRSTNAME")), '') as firstname,
        nullif(trim(to_varchar("INTERMEDIARY")), '') as intermediary,
        nullif(trim(to_varchar("LOCATIONCODE")), '') as locationcode,
        nullif(trim(to_varchar("MARITALSTATUS")), '') as maritalstatus,
        nullif(trim(to_varchar("MIDDLENAME")), '') as middlename,
        nullif(trim(to_varchar("MOBILENUMBER")), '') as mobilenumber,
        nullif(trim(to_varchar("PAN_VALID_STATUS")), '') as pan_valid_status,
        nullif(trim(to_varchar("PARTNERID")), '') as partnerid,
        nullif(trim(to_varchar("PASSPORTNO")), '') as passportno,
        nullif(trim(to_varchar("PAYMENTMODE")), '') as paymentmode,
        nullif(trim(to_varchar("PCONTRACTID")), '') as pcontractid,
        nullif(trim(to_varchar("PGROSSPREMIUM")), '') as pgrosspremium,
        nullif(trim(to_varchar("PINCODE")), '') as pincode,
        nullif(trim(to_varchar("PLANID")), '') as planid,
        nullif(trim(to_varchar("PMASTERPOLICYNUMBER")), '') as pmasterpolicynumber,
        nullif(trim(to_varchar("POLICYISSUEDATE")), '') as policyissuedate,
        nullif(trim(to_varchar("POLICYNUMBER")), '') as policynumber,
        nullif(trim(to_varchar("PREMIUMPAYERID")), '') as premiumpayerid,
        nullif(trim(to_varchar("PSERVICETAX")), '') as pservicetax,
        nullif(trim(to_varchar("PSTARTDATE")), '') as pstartdate,
        nullif(trim(to_varchar("PTODATE")), '') as ptodate,
        nullif(trim(to_varchar("PTOTALPREMIUM")), '') as ptotalpremium,
        nullif(trim(to_varchar("SCHEMECODE")), '') as schemecode,
        nullif(trim(to_varchar("SEX")), '') as sex,
        nullif(trim(to_varchar("STATE")), '') as state,
        nullif(trim(to_varchar("STREETNAME")), '') as streetname,
        nullif(trim(to_varchar("SUM_INSURED")), '') as sum_insured,
        nullif(trim(to_varchar("SURNAME")), '') as surname,
        nullif(trim(to_varchar("TELEPHONE")), '') as telephone,
        nullif(trim(to_varchar("TITLE")), '') as title
    from {{ source('health_raw', 'BJAZ_GENERIC_LOADER_LOG_TABLE') }}

)

select * from source
