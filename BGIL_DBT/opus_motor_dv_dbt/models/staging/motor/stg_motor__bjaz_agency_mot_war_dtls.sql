-- Staging for source table BJAZ_AGENCY_MOT_WAR_DTLS. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("REFERENCE_ID")), '') as reference_id,
        nullif(trim(to_varchar("VEHICLE_TYPE")), '') as vehicle_type,
        nullif(trim(to_varchar("VEHICLE_MAKE")), '') as vehicle_make,
        nullif(trim(to_varchar("VEHICLE_MODEL")), '') as vehicle_model,
        nullif(trim(to_varchar("TRANS_TYPE")), '') as trans_type,
        nullif(trim(to_varchar("FUEL_TYPE")), '') as fuel_type,
        nullif(trim(to_varchar("EW_PLAN")), '') as ew_plan,
        nullif(trim(to_varchar("CERT_SALE_DATE")), '') as cert_sale_date,
        nullif(trim(to_varchar("EQUIP_SALE_DATE")), '') as equip_sale_date,
        nullif(trim(to_varchar("VEH_DELIVERY_DATE")), '') as veh_delivery_date,
        nullif(trim(to_varchar("PINCODE")), '') as pincode,
        nullif(trim(to_varchar("VEH_INVOICE_PRICE")), '') as veh_invoice_price,
        nullif(trim(to_varchar("MOB_NO")), '') as mob_no,
        nullif(trim(to_varchar("CHASSIS_NO")), '') as chassis_no,
        nullif(trim(to_varchar("ENGINE_NO")), '') as engine_no,
        nullif(trim(to_varchar("INVOICE_NO")), '') as invoice_no,
        nullif(trim(to_varchar("VEH_REG_NO")), '') as veh_reg_no,
        nullif(trim(to_varchar("CURRENT_ODOMETER_READING")), '') as current_odometer_reading,
        nullif(trim(to_varchar("YEAR_OF_MANUFACTURING")), '') as year_of_manufacturing,
        nullif(trim(to_varchar("TITLE")), '') as title,
        nullif(trim(to_varchar("YOUR_NAME")), '') as your_name,
        nullif(trim(to_varchar("EMAIL_ID")), '') as email_id,
        nullif(trim(to_varchar("CUSTOMER_ADDRESS")), '') as customer_address,
        nullif(trim(to_varchar("STATE")), '') as state,
        nullif(trim(to_varchar("CITY")), '') as city,
        nullif(trim(to_varchar("AREA")), '') as area,
        nullif(trim(to_varchar("GSTIN_NO")), '') as gstin_no,
        nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref,
        nullif(trim(to_varchar("PAYMENT_MODE")), '') as payment_mode,
        nullif(trim(to_varchar("SCRUTINY_NO")), '') as scrutiny_no,
        nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
        nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
        nullif(trim(to_varchar("INSERT_DATE")), '') as insert_date,
        nullif(trim(to_varchar("GROSS_PREMIUM")), '') as gross_premium,
        nullif(trim(to_varchar("IMD_CODE")), '') as imd_code,
        nullif(trim(to_varchar("USER_NAME")), '') as user_name,
        nullif(trim(to_varchar("MASTER_POLICY")), '') as master_policy,
        nullif(trim(to_varchar("SGST")), '') as sgst,
        nullif(trim(to_varchar("CGST")), '') as cgst,
        nullif(trim(to_varchar("IGST")), '') as igst,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_test_raw', 'BJAZ_AGENCY_MOT_WAR_DTLS') }}

)

select * from source
