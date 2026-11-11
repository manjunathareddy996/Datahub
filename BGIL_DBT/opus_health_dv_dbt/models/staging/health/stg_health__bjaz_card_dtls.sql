-- Staging for source table BJAZ_CARD_DTLS (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("AGE")), '') as age,
        nullif(trim(to_varchar("ASSIGNEE")), '') as assignee,
        nullif(trim(to_varchar("BASE_SI")), '') as base_si,
        nullif(trim(to_varchar("CARD_EXPIRY")), '') as card_expiry,
        nullif(trim(to_varchar("CARD_NO")), '') as card_no,
        nullif(trim(to_varchar("CARD_SEND_TO_PERSON_NAME")), '') as card_send_to_person_name,
        nullif(trim(to_varchar("CARD_STATUS")), '') as card_status,
        nullif(trim(to_varchar("CARD_TYPE")), '') as card_type,
        nullif(trim(to_varchar("COMPANY_NAME")), '') as company_name,
        nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
        nullif(trim(to_varchar("DATE_OF_JOINING")), '') as date_of_joining,
        nullif(trim(to_varchar("DOB")), '') as dob,
        nullif(trim(to_varchar("EFF_DATE")), '') as eff_date,
        nullif(trim(to_varchar("EMP_NO")), '') as emp_no,
        nullif(trim(to_varchar("EXPIRY_DATE")), '') as expiry_date,
        nullif(trim(to_varchar("FLOATER_OR_NOT")), '') as floater_or_not,
        nullif(trim(to_varchar("GENDER")), '') as gender,
        nullif(trim(to_varchar("MEMBER_NAME")), '') as member_name,
        nullif(trim(to_varchar("MEMBER_TYPE")), '') as member_type,
        nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
        nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref,
        nullif(trim(to_varchar("POLICY_TYPE")), '') as policy_type,
        nullif(trim(to_varchar("RELATION")), '') as relation,
        nullif(trim(to_varchar("RELATION_DESC")), '') as relation_desc,
        nullif(trim(to_varchar("STATUS")), '') as status,
        nullif(trim(to_varchar("SUM_INSURED")), '') as sum_insured
    from {{ source('health_raw', 'BJAZ_CARD_DTLS') }}

)

select * from source
