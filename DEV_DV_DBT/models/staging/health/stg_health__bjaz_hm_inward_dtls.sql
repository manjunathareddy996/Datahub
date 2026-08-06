-- Staging model for source table BJAZ_HM_INWARD_DTLS (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim("CALLER_CONTACT_NO"::varchar), '') as caller_contact_no,
    nullif(trim("CALLER_EMAIL_ID"::varchar), '') as caller_email_id,
    nullif(trim("CERTIFICATE_NO"::varchar), '') as certificate_no,
    nullif(trim("CITY_NAME"::varchar), '') as city_name,
    nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
    nullif(trim(to_varchar("CLID_HPMS")), '') as clid_hpms,
    nullif(trim(to_varchar("COURIER_ID")), '') as courier_id,
    "DOC_REC_DATE"::timestamp_ntz as doc_rec_date,
    nullif(trim("EMAIL_ID"::varchar), '') as email_id,
    nullif(trim("GEO_AREA"::varchar), '') as geo_area,
    nullif(trim("ID_CARD_NO"::varchar), '') as id_card_no,
    nullif(trim("INSURED_CONTACT_NO"::varchar), '') as insured_contact_no,
    nullif(trim("INSURED_EMAIL_ID"::varchar), '') as insured_email_id,
    nullif(trim(to_varchar("INWARD_ID")), '') as inward_id,
    nullif(trim("INWARD_NO"::varchar), '') as inward_no,
    nullif(trim(to_varchar("LOCATION_CODE")), '') as location_code,
    nullif(trim("MEMBER_NAME"::varchar), '') as member_name,
    nullif(trim("MOBILE_NO"::varchar), '') as mobile_no,
    nullif(trim(to_varchar("OUTWARD_ID")), '') as outward_id,
    nullif(trim("PASSPORT_NO"::varchar), '') as passport_no,
    nullif(trim("PERTAIN_TO"::varchar), '') as pertain_to,
    "PIN_CODE"::number as pin_code,
    nullif(trim("PLAN_NAME"::varchar), '') as plan_name,
    nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref,
    nullif(trim("PROPOSER_NAME"::varchar), '') as proposer_name,
    nullif(trim("SENDER_NAME"::varchar), '') as sender_name,
    nullif(trim("STATE_NAME"::varchar), '') as state_name,
    nullif(trim("TYPE_OF_LOSS"::varchar), '') as type_of_loss,
    nullif(trim("VIP_FLAG"::varchar), '') as vip_flag
    from {{ source('health_raw', 'BJAZ_HM_INWARD_DTLS') }}

)

select * from source
