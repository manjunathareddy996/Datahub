-- Staging model for source table BJAZ_AZBJ_PART_EXT_HIST (Partner LOB).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, TIMESTAMP/DATE -> TIMESTAMP_NTZ.
-- Key columns (hub-key components) -> canonical trimmed VARCHAR regardless of native type,
-- for stable hashing -- same convention as the Health LOB build.

with source as (

    select
    nullif(trim("PA_CODE"::varchar), '') as pa_code,
    nullif(trim("SUBCODE"::varchar), '') as subcode,
    nullif(trim("EMP_ID"::varchar), '') as emp_id,
    nullif(trim("AA_MEMBERSHIP_NUMBER"::varchar), '') as aa_membership_number,
    "AA_MEMBERSHIP_EXPIRY_DATE"::timestamp_ntz as aa_membership_expiry_date,
    nullif(trim("OCCUPATION_DESC_GEN"::varchar), '') as occupation_desc_gen,
    "PAIDUP_CAPITAL"::number as paidup_capital,
    nullif(trim("IFSC_CODE"::varchar), '') as ifsc_code,
    nullif(trim("AVAILABILITY_TIME"::varchar), '') as availability_time,
    nullif(trim("AVAILABILITY_AT"::varchar), '') as availability_at,
    nullif(trim(to_varchar("PART_ID")), '') as part_id,
    nullif(trim(to_varchar("MAIL_ADD_ID")), '') as mail_add_id,
    "INDUSTRY"::number as industry,
    nullif(trim("FATHER_NAME"::varchar), '') as father_name,
    nullif(trim("PLACE_OF_BIRTH"::varchar), '') as place_of_birth,
    nullif(trim("EDUCATION"::varchar), '') as education,
    nullif(trim("IT_STATUS"::varchar), '') as it_status,
    nullif(trim("MICR_CODE"::varchar), '') as micr_code,
    nullif(trim("ACC_TYPE"::varchar), '') as acc_type,
    nullif(trim("ACCOUNT_NO"::varchar), '') as account_no,
    nullif(trim("ECS_STATUS"::varchar), '') as ecs_status,
    nullif(trim("VIP_CUST"::varchar), '') as vip_cust,
    nullif(trim("EMAIL_2"::varchar), '') as email_2,
    "UPD_DT"::timestamp_ntz as upd_dt,
    nullif(trim("USER_NAME"::varchar), '') as user_name,
    nullif(trim("MACHINE"::varchar), '') as machine,
    nullif(trim("PROGRAM"::varchar), '') as program,
    nullif(trim("EIA_NO"::varchar), '') as eia_no,
    nullif(trim("WEB_USER_ID"::varchar), '') as web_user_id,
    nullif(trim("ACTION"::varchar), '') as action,
    nullif(trim("MODULE"::varchar), '') as module,
    "GG_CHANGE_DATE"::timestamp_ntz as gg_change_date,
    nullif(trim("TELEPHONE3"::varchar), '') as telephone3,
    nullif(trim("PARTNER_REF_NO"::varchar), '') as partner_ref_no,
    nullif(trim("GLOBAL_CO_NAME"::varchar), '') as global_co_name,
    nullif(trim("PARENT_CO"::varchar), '') as parent_co,
    nullif(trim("PARENT_ID"::varchar), '') as parent_id,
    nullif(trim("CO_NUMBER"::varchar), '') as co_number
    from {{ source('partner_raw', 'BJAZ_AZBJ_PART_EXT_HIST') }}

)

select * from source
