-- Staging model for source table BJAZ_HM_HOSPITAL_MASTER (Partner LOB).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, TIMESTAMP/DATE -> TIMESTAMP_NTZ.
-- Key columns (hub-key components) -> canonical trimmed VARCHAR regardless of native type,
-- for stable hashing -- same convention as the Health LOB build.

with source as (

    select
    nullif(trim(to_varchar("HOSID")), '') as hosid,
    nullif(trim("HOSPITAL_NAME"::varchar), '') as hospital_name,
    nullif(trim("ADDRESS1"::varchar), '') as address1,
    nullif(trim("ADDRESS2"::varchar), '') as address2,
    nullif(trim("CITY_NAME"::varchar), '') as city_name,
    nullif(trim("PIN_CODE"::varchar), '') as pin_code,
    nullif(trim("STD_CODE"::varchar), '') as std_code,
    nullif(trim("PHONE_NO"::varchar), '') as phone_no,
    nullif(trim("FAX_NO"::varchar), '') as fax_no,
    nullif(trim("CONTACT_PERSON"::varchar), '') as contact_person,
    nullif(trim("DESIGNATION"::varchar), '') as designation,
    "HOS_STATUS"::number as hos_status,
    "NETWORK_TYPE"::number as network_type,
    nullif(trim("DISCOUNT"::varchar), '') as discount,
    nullif(trim("DISCOUNT_ON"::varchar), '') as discount_on,
    "DATE_OF_SUP"::timestamp_ntz as date_of_sup,
    "EMPANEL_DATE"::timestamp_ntz as empanel_date,
    nullif(trim("BENNAME"::varchar), '') as benname,
    nullif(trim("HOS_REMARK"::varchar), '') as hos_remark,
    "PREFERRED_FLAG"::number as preferred_flag,
    "UPDATED_ON"::timestamp_ntz as updated_on,
    nullif(trim("UPDATED_BY"::varchar), '') as updated_by,
    "DELETE_FLAG"::number as delete_flag,
    nullif(trim("STATE_NAME"::varchar), '') as state_name,
    nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
    "EFFECTIVE_DATE"::timestamp_ntz as effective_date,
    "EXPIRY_DATE"::timestamp_ntz as expiry_date,
    nullif(trim("EMAIL"::varchar), '') as email,
    nullif(trim("STAX_REG_NO"::varchar), '') as stax_reg_no,
    "DIAGNO_YN"::number as diagno_yn,
    nullif(trim("HOSPITAL_NO"::varchar), '') as hospital_no,
    nullif(trim("PRIORITY_FLG"::varchar), '') as priority_flg,
    nullif(trim("HOSP_TYPE"::varchar), '') as hosp_type,
    nullif(trim("HOSP_SPECIALITY"::varchar), '') as hosp_speciality,
    nullif(trim("HOSP_SPEC_TYPE"::varchar), '') as hosp_spec_type,
    nullif(trim("PAYMENT_MODE"::varchar), '') as payment_mode,
    "IMPS_ACTIVE_DATE"::timestamp_ntz as imps_active_date,
    "IMPS_END_DATE"::timestamp_ntz as imps_end_date,
    "EARLY_DISCOUNT"::number as early_discount,
    "IMPS_DISCNT"::number as imps_discnt,
    nullif(trim("IMPS_DISCNT_ON"::varchar), '') as imps_discnt_on,
    "IMPS_TARIF_FRM"::timestamp_ntz as imps_tarif_frm,
    "IMPS_TARIF_TO"::timestamp_ntz as imps_tarif_to,
    "IMPS_PAYMENT_LMT"::number as imps_payment_lmt,
    "GG_CHANGE_DATE"::timestamp_ntz as gg_change_date
    from {{ source('partner_raw', 'BJAZ_HM_HOSPITAL_MASTER') }}

)

select * from source
