-- Staging for source table BJAZ_CLM_MOT_TAX_DTLS. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
        nullif(trim(to_varchar("TAX_RECP_NO")), '') as tax_recp_no,
        nullif(trim(to_varchar("TAX_RECP_ISSUE_DATE")), '') as tax_recp_issue_date,
        nullif(trim(to_varchar("TAX_RECP_EXP_DATE")), '') as tax_recp_exp_date,
        nullif(trim(to_varchar("FITNESS_CERT_NO")), '') as fitness_cert_no,
        nullif(trim(to_varchar("FITNESS_ISSUE_DATE")), '') as fitness_issue_date,
        nullif(trim(to_varchar("FITNESS_EXP_DATE")), '') as fitness_exp_date,
        nullif(trim(to_varchar("ROUTE_PERMIT_NO")), '') as route_permit_no,
        nullif(trim(to_varchar("ROUTE_ISSUE_DATE")), '') as route_issue_date,
        nullif(trim(to_varchar("ROUTE_EXP_DATE")), '') as route_exp_date,
        nullif(trim(to_varchar("GOOD_PERMIT_NO")), '') as good_permit_no,
        nullif(trim(to_varchar("GOOD_ISSUE_DATE")), '') as good_issue_date,
        nullif(trim(to_varchar("GOOD_EXP_DATE")), '') as good_exp_date,
        nullif(trim(to_varchar("GOODS_TYPE")), '') as goods_type,
        nullif(trim(to_varchar("ORIGIN_PLACE")), '') as origin_place,
        nullif(trim(to_varchar("DESTINATION")), '') as destination,
        nullif(trim(to_varchar("WEIGHT_CARRIED")), '') as weight_carried,
        nullif(trim(to_varchar("CHALLAN_DTLS")), '') as challan_dtls,
        nullif(trim(to_varchar("CHALLAN_DATE")), '') as challan_date,
        nullif(trim(to_varchar("INSERT_DATE")), '') as insert_date,
        nullif(trim(to_varchar("INSERTED_BY")), '') as inserted_by,
        nullif(trim(to_varchar("LAST_UPDATED_DATE")), '') as last_updated_date,
        nullif(trim(to_varchar("LAST_UPDATED_BY")), '') as last_updated_by,
        nullif(trim(to_varchar("DRIVING_LICENSE_TYPE")), '') as driving_license_type,
        nullif(trim(to_varchar("VEHICLE_PARKED")), '') as vehicle_parked,
        nullif(trim(to_varchar("SURVEYOR_UPDATE")), '') as surveyor_update,
        nullif(trim(to_varchar("DRIVER_LIC_ISSUE_DATE")), '') as driver_lic_issue_date,
        nullif(trim(to_varchar("TELEPHONE_NO")), '') as telephone_no,
        nullif(trim(to_varchar("EMAIL_ID")), '') as email_id,
        nullif(trim(to_varchar("FLAG_WEB")), '') as flag_web,
        nullif(trim(to_varchar("SPOT_SUR_UPDATE")), '') as spot_sur_update,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_raw', 'BJAZ_CLM_MOT_TAX_DTLS') }}

)

select * from source
