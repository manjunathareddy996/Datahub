-- Staging for source table BJAZ_MOT_WAR_CHILD_DTLS. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("ACTION_CODE")), '') as action_code,
        nullif(trim(to_varchar("VERSION_NO")), '') as version_no,
        nullif(trim(to_varchar("TOP_INDICATOR")), '') as top_indicator,
        nullif(trim(to_varchar("PREVIOUS_VERSION")), '') as previous_version,
        nullif(trim(to_varchar("REVERSING_VERSION")), '') as reversing_version,
        nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
        nullif(trim(to_varchar("EXT_WARRANTY_CERT_NO")), '') as ext_warranty_cert_no,
        nullif(trim(to_varchar("CERT_SALE_DATE")), '') as cert_sale_date,
        nullif(trim(to_varchar("DEALER_CODE")), '') as dealer_code,
        nullif(trim(to_varchar("STATE")), '') as state,
        nullif(trim(to_varchar("CITY")), '') as city,
        nullif(trim(to_varchar("MAKE_NAME")), '') as make_name,
        nullif(trim(to_varchar("MODEL_NAME")), '') as model_name,
        nullif(trim(to_varchar("EQUIPMENT_SERIAL_NO")), '') as equipment_serial_no,
        nullif(trim(to_varchar("ENGINE_NO")), '') as engine_no,
        nullif(trim(to_varchar("EQUIPMENT_SALE_DATE")), '') as equipment_sale_date,
        nullif(trim(to_varchar("PLAN_DESC")), '') as plan_desc,
        nullif(trim(to_varchar("MFG_WARRANTY_PERIOD")), '') as mfg_warranty_period,
        nullif(trim(to_varchar("EXTENDED_WARRANTY_PERIOD")), '') as extended_warranty_period,
        nullif(trim(to_varchar("EXT_WARRANTY_START_DATE")), '') as ext_warranty_start_date,
        nullif(trim(to_varchar("EXT_WARRANTY_END_DATE")), '') as ext_warranty_end_date,
        nullif(trim(to_varchar("CUSTOMER_NAME")), '') as customer_name,
        nullif(trim(to_varchar("SPECIAL_CONDITIONS")), '') as special_conditions,
        nullif(trim(to_varchar("UNDERWRITING_LOADING")), '') as underwriting_loading,
        nullif(trim(to_varchar("COMMERCIAL_DISCOUNT")), '') as commercial_discount,
        nullif(trim(to_varchar("INSERTED_BY")), '') as inserted_by,
        nullif(trim(to_varchar("INSERT_DATE")), '') as insert_date,
        nullif(trim(to_varchar("UPDATED_BY")), '') as updated_by,
        nullif(trim(to_varchar("UPDATE_DATE")), '') as update_date,
        nullif(trim(to_varchar("MOBILE_NO")), '') as mobile_no,
        nullif(trim(to_varchar("TEL_NO")), '') as tel_no,
        nullif(trim(to_varchar("EMAIL_ID")), '') as email_id,
        nullif(trim(to_varchar("OUTLET_CODE")), '') as outlet_code,
        nullif(trim(to_varchar("DATE_OF_VEH_DELIVERY")), '') as date_of_veh_delivery,
        nullif(trim(to_varchar("VEHICLE_REG_NO")), '') as vehicle_reg_no,
        nullif(trim(to_varchar("MOTOR_POLICY_NO")), '') as motor_policy_no,
        nullif(trim(to_varchar("MOTOR_COVERNOTE_NO")), '') as motor_covernote_no,
        nullif(trim(to_varchar("VEHICLE_SOLD_FROM")), '') as vehicle_sold_from,
        nullif(trim(to_varchar("SALES_PERSON_NAME")), '') as sales_person_name,
        nullif(trim(to_varchar("PRESENT_KM")), '') as present_km,
        nullif(trim(to_varchar("PRESENT_HOUR")), '') as present_hour,
        nullif(trim(to_varchar("FUEL_TYPE")), '') as fuel_type,
        nullif(trim(to_varchar("ITL_EW_REFERENCE")), '') as itl_ew_reference,
        nullif(trim(to_varchar("FLOAT_TYPE")), '') as float_type,
        nullif(trim(to_varchar("PPID")), '') as ppid,
        nullif(trim(to_varchar("GST_NO")), '') as gst_no,
        nullif(trim(to_varchar("PAN_NO")), '') as pan_no,
        nullif(trim(to_varchar("YEAR_OF_MANUFACTURING")), '') as year_of_manufacturing,
        nullif(trim(to_varchar("INVOICE_DATE")), '') as invoice_date,
        nullif(trim(to_varchar("OWNERSHIP_NO")), '') as ownership_no,
        nullif(trim(to_varchar("SEQID")), '') as seqid,
        nullif(trim(to_varchar("MOTOR_NO2")), '') as motor_no2,
        nullif(trim(to_varchar("INVOICE_NO")), '') as invoice_no,
        nullif(trim(to_varchar("CUSTOMER_CONSENT")), '') as customer_consent,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        nullif(trim(to_varchar("EREQNO")), '') as ereqno,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_raw', 'BJAZ_MOT_WAR_CHILD_DTLS') }}

)

select * from source
