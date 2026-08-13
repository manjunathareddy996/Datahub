-- Staging model for source table BJAZ_WS_FAMILY_DTLS_BANDHAN (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim("FAMILYCOMBINATION"::varchar), '') as familycombination,
    nullif(trim("MEMBER1DOB"::varchar), '') as member1dob,
    nullif(trim("MEMBER1GENDER"::varchar), '') as member1gender,
    nullif(trim("MEMBER1NAME"::varchar), '') as member1name,
    nullif(trim("MEMBER1PASSPORTNO"::varchar), '') as member1passportno,
    nullif(trim("MEMBER1PREEXISITNGDISEASE"::varchar), '') as member1preexisitngdisease,
    nullif(trim("MEMBER1RELATION"::varchar), '') as member1relation,
    nullif(trim("MEMBER2DOB"::varchar), '') as member2dob,
    nullif(trim("MEMBER2GENDER"::varchar), '') as member2gender,
    nullif(trim("MEMBER2NAME"::varchar), '') as member2name,
    nullif(trim("MEMBER2PASSPORTNO"::varchar), '') as member2passportno,
    nullif(trim("MEMBER2PREEXISITNGDISEASE"::varchar), '') as member2preexisitngdisease,
    nullif(trim("MEMBER2RELATION"::varchar), '') as member2relation,
    nullif(trim("MEMBER3DOB"::varchar), '') as member3dob,
    nullif(trim("MEMBER3GENDER"::varchar), '') as member3gender,
    nullif(trim("MEMBER3NAME"::varchar), '') as member3name,
    nullif(trim("MEMBER3PASSPORTNO"::varchar), '') as member3passportno,
    nullif(trim("MEMBER3PREEXISITNGDISEASE"::varchar), '') as member3preexisitngdisease,
    nullif(trim("MEMBER3RELATION"::varchar), '') as member3relation,
    nullif(trim("MEMBER4DOB"::varchar), '') as member4dob,
    nullif(trim("MEMBER4GENDER"::varchar), '') as member4gender,
    nullif(trim("MEMBER4NAME"::varchar), '') as member4name,
    nullif(trim("MEMBER4PASSPORTNO"::varchar), '') as member4passportno,
    nullif(trim("MEMBER4PREEXISITNGDISEASE"::varchar), '') as member4preexisitngdisease,
    nullif(trim("MEMBER4RELATION"::varchar), '') as member4relation,
    nullif(trim("MEMBER5DOB"::varchar), '') as member5dob,
    nullif(trim("MEMBER5GENDER"::varchar), '') as member5gender,
    nullif(trim("MEMBER5NAME"::varchar), '') as member5name,
    nullif(trim("MEMBER5PASSPORTNO"::varchar), '') as member5passportno,
    nullif(trim("MEMBER5PREEXISITNGDISEASE"::varchar), '') as member5preexisitngdisease,
    nullif(trim("MEMBER5RELATION"::varchar), '') as member5relation,
    nullif(trim("MEMBER6DOB"::varchar), '') as member6dob,
    nullif(trim("MEMBER6GENDER"::varchar), '') as member6gender,
    nullif(trim("MEMBER6NAME"::varchar), '') as member6name,
    nullif(trim("MEMBER6PASSPORTNO"::varchar), '') as member6passportno,
    nullif(trim("MEMBER6PREEXISITNGDISEASE"::varchar), '') as member6preexisitngdisease,
    nullif(trim("MEMBER6RELATION"::varchar), '') as member6relation,
    nullif(trim("MEMBER7DOB"::varchar), '') as member7dob,
    nullif(trim("MEMBER7GENDER"::varchar), '') as member7gender,
    nullif(trim("MEMBER7NAME"::varchar), '') as member7name,
    nullif(trim("MEMBER7PASSPORTNO"::varchar), '') as member7passportno,
    nullif(trim("MEMBER7PREEXISITNGDISEASE"::varchar), '') as member7preexisitngdisease,
    nullif(trim("MEMBER7RELATION"::varchar), '') as member7relation,
    nullif(trim("MEMBER8DOB"::varchar), '') as member8dob,
    nullif(trim("MEMBER8GENDER"::varchar), '') as member8gender,
    nullif(trim("MEMBER8NAME"::varchar), '') as member8name,
    nullif(trim("MEMBER8PASSPORTNO"::varchar), '') as member8passportno,
    nullif(trim("MEMBER8PREEXISITNGDISEASE"::varchar), '') as member8preexisitngdisease,
    nullif(trim("MEMBER8RELATION"::varchar), '') as member8relation,
    nullif(trim("PLAN_NAME"::varchar), '') as plan_name,
    nullif(trim(to_varchar("PMASTERPOLICYNUMBER")), '') as pmasterpolicynumber,
    nullif(trim("SELFDOB"::varchar), '') as selfdob,
    nullif(trim("SELFGENDER"::varchar), '') as selfgender,
    nullif(trim("SELFNAME"::varchar), '') as selfname,
    nullif(trim("SELFPASSPORTNO"::varchar), '') as selfpassportno,
    nullif(trim("SELFPREEXISITNGDISEASE"::varchar), '') as selfpreexisitngdisease,
    nullif(trim("SELFRELATION"::varchar), '') as selfrelation
    from {{ source('health_raw', 'BJAZ_WS_FAMILY_DTLS_BANDHAN') }}

)

select * from source
