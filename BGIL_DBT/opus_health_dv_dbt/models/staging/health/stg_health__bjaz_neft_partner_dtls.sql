-- Staging for source table BJAZ_NEFT_PARTNER_DTLS (run opus_health_v2). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("ADDRESS_ID")), '') as address_id,
        nullif(trim(to_varchar("APPROVED_BY")), '') as approved_by,
        nullif(trim(to_varchar("APPROVED_DATE")), '') as approved_date,
        nullif(trim(to_varchar("APPROVED_STATUS")), '') as approved_status,
        nullif(trim(to_varchar("AREA")), '') as area,
        nullif(trim(to_varchar("BRANCH_CONTACT_NO_2")), '') as branch_contact_no_2,
        nullif(trim(to_varchar("CITY")), '') as city,
        nullif(trim(to_varchar("EMAIL_ID")), '') as email_id,
        nullif(trim(to_varchar("EMAIL_ID_2")), '') as email_id_2,
        nullif(trim(to_varchar("EMAIL_ID_3")), '') as email_id_3,
        nullif(trim(to_varchar("HO_ENABLED_DATE")), '') as ho_enabled_date,
        nullif(trim(to_varchar("HO_ENABLED_USER")), '') as ho_enabled_user,
        nullif(trim(to_varchar("INTERMEDIARY_ID")), '') as intermediary_id,
        nullif(trim(to_varchar("MANDATE_ADDRESS")), '') as mandate_address,
        nullif(trim(to_varchar("MOBILE_NO")), '') as mobile_no,
        nullif(trim(to_varchar("OTH_REJECT_REASON")), '') as oth_reject_reason,
        nullif(trim(to_varchar("PART_ID")), '') as part_id,
        nullif(trim(to_varchar("PINCODE")), '') as pincode,
        nullif(trim(to_varchar("REJECT_REASON")), '') as reject_reason,
        nullif(trim(to_varchar("REQUESTED_BY")), '') as requested_by,
        nullif(trim(to_varchar("REQUESTED_DATE")), '') as requested_date,
        nullif(trim(to_varchar("REQ_UPDATE_REASON")), '') as req_update_reason,
        nullif(trim(to_varchar("REQ_UPDATE_STATUS")), '') as req_update_status,
        nullif(trim(to_varchar("RESP_APPROVER")), '') as resp_approver,
        nullif(trim(to_varchar("RE_ENTERED_ACC_NO")), '') as re_entered_acc_no,
        nullif(trim(to_varchar("STATE")), '') as state,
        nullif(trim(to_varchar("SUPPLIER_ID")), '') as supplier_id,
        nullif(trim(to_varchar("SUPPLIER_TYPE")), '') as supplier_type
    from {{ source('health_raw', 'BJAZ_NEFT_PARTNER_DTLS') }}

)

select * from source
