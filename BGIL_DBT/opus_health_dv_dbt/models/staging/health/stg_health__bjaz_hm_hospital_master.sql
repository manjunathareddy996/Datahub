-- Staging for source table BJAZ_HM_HOSPITAL_MASTER (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("ADDRESS1")), '') as address1,
        nullif(trim(to_varchar("ADDRESS2")), '') as address2,
        nullif(trim(to_varchar("BENNAME")), '') as benname,
        nullif(trim(to_varchar("CITY_NAME")), '') as city_name,
        nullif(trim(to_varchar("CONTACT_PERSON")), '') as contact_person,
        nullif(trim(to_varchar("DATE_OF_SUP")), '') as date_of_sup,
        nullif(trim(to_varchar("DESIGNATION")), '') as designation,
        nullif(trim(to_varchar("DIAGNO_YN")), '') as diagno_yn,
        nullif(trim(to_varchar("DISCOUNT")), '') as discount,
        nullif(trim(to_varchar("DISCOUNT_ON")), '') as discount_on,
        nullif(trim(to_varchar("EARLY_DISCOUNT")), '') as early_discount,
        nullif(trim(to_varchar("EFFECTIVE_DATE")), '') as effective_date,
        nullif(trim(to_varchar("EMAIL")), '') as email,
        nullif(trim(to_varchar("EMPANEL_DATE")), '') as empanel_date,
        nullif(trim(to_varchar("EXPIRY_DATE")), '') as expiry_date,
        nullif(trim(to_varchar("FAX_NO")), '') as fax_no,
        nullif(trim(to_varchar("HOSID")), '') as hosid,
        nullif(trim(to_varchar("HOSPITAL_NAME")), '') as hospital_name,
        nullif(trim(to_varchar("HOSPITAL_NO")), '') as hospital_no,
        nullif(trim(to_varchar("HOSP_SPECIALITY")), '') as hosp_speciality,
        nullif(trim(to_varchar("HOSP_SPEC_TYPE")), '') as hosp_spec_type,
        nullif(trim(to_varchar("HOSP_TYPE")), '') as hosp_type,
        nullif(trim(to_varchar("HOS_REMARK")), '') as hos_remark,
        nullif(trim(to_varchar("HOS_STATUS")), '') as hos_status,
        nullif(trim(to_varchar("IMPS_ACTIVE_DATE")), '') as imps_active_date,
        nullif(trim(to_varchar("IMPS_DISCNT")), '') as imps_discnt,
        nullif(trim(to_varchar("IMPS_DISCNT_ON")), '') as imps_discnt_on,
        nullif(trim(to_varchar("IMPS_END_DATE")), '') as imps_end_date,
        nullif(trim(to_varchar("IMPS_PAYMENT_LMT")), '') as imps_payment_lmt,
        nullif(trim(to_varchar("IMPS_TARIF_FRM")), '') as imps_tarif_frm,
        nullif(trim(to_varchar("IMPS_TARIF_TO")), '') as imps_tarif_to,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at,
        nullif(trim(to_varchar("NETWORK_TYPE")), '') as network_type,
        nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
        nullif(trim(to_varchar("PAYMENT_MODE")), '') as payment_mode,
        nullif(trim(to_varchar("PHONE_NO")), '') as phone_no,
        nullif(trim(to_varchar("PIN_CODE")), '') as pin_code,
        nullif(trim(to_varchar("PREFERRED_FLAG")), '') as preferred_flag,
        nullif(trim(to_varchar("PRIORITY_FLG")), '') as priority_flg,
        nullif(trim(to_varchar("STATE_NAME")), '') as state_name,
        nullif(trim(to_varchar("STAX_REG_NO")), '') as stax_reg_no,
        nullif(trim(to_varchar("STD_CODE")), '') as std_code
    from {{ source('health_raw', 'BJAZ_HM_HOSPITAL_MASTER') }}

)

select * from source
