-- Staging model for source table AZBJ_PARTNER_EXTN (Partner LOB).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, TIMESTAMP/DATE -> TIMESTAMP_NTZ.
-- Key columns (hub-key components) -> canonical trimmed VARCHAR regardless of native type,
-- for stable hashing -- same convention as the Health LOB build.

with source as (

    select
    nullif(trim("EMP_ID"::varchar), '') as emp_id,
    nullif(trim("AA_MEMBERSHIP_NUMBER"::varchar), '') as aa_membership_number,
    "AA_MEMBERSHIP_EXPIRY_DATE"::timestamp_ntz as aa_membership_expiry_date,
    nullif(trim("TELEPHONE3"::varchar), '') as telephone3,
    nullif(trim("PARTNER_REF_NO"::varchar), '') as partner_ref_no,
    nullif(trim("GLOBAL_CO_NAME"::varchar), '') as global_co_name,
    nullif(trim("PARENT_CO"::varchar), '') as parent_co,
    nullif(trim("PART_ID"::varchar), '') as part_id,
    nullif(trim("MAIL_ADD_ID"::varchar), '') as mail_add_id,
    "INDUSTRY"::number as industry,
    nullif(trim("FATHER_NAME"::varchar), '') as father_name,
    nullif(trim("PLACE_OF_BIRTH"::varchar), '') as place_of_birth,
    nullif(trim("EDUCATION"::varchar), '') as education,
    nullif(trim("PA_CODE"::varchar), '') as pa_code,
    nullif(trim("SUBCODE"::varchar), '') as subcode,
    nullif(trim("PARENT_ID"::varchar), '') as parent_id,
    nullif(trim("CO_NUMBER"::varchar), '') as co_number,
    nullif(trim("OCCUPATION_DESC_GEN"::varchar), '') as occupation_desc_gen,
    "PAIDUP_CAPITAL"::number as paidup_capital,
    nullif(trim("IFSC_CODE"::varchar), '') as ifsc_code,
    nullif(trim("AVAILABILITY_TIME"::varchar), '') as availability_time,
    nullif(trim("AVAILABILITY_AT"::varchar), '') as availability_at,
    nullif(trim("IT_STATUS"::varchar), '') as it_status,
    nullif(trim("SPOUSE_NAME"::varchar), '') as spouse_name,
    "NO_OF_CHILDREN"::number as no_of_children,
    "SONS"::number as sons,
    "DAUGHTERS"::number as daughters,
    nullif(trim("FAMILY_MONTHLY_INCOME"::varchar), '') as family_monthly_income,
    "FAMILY_ID"::number as family_id,
    "CLUSTER_ID"::number as cluster_id,
    "GG_CHANGE_DATE"::timestamp_ntz as gg_change_date,
    "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at,
    nullif(trim("FROM_MODULE"::varchar), '') as from_module,
    nullif(trim("EXISTING_CUST"::varchar), '') as existing_cust,
    nullif(trim("WEBSITE"::varchar), '') as website,
    nullif(trim("UCIC_FLAG"::varchar), '') as ucic_flag,
    nullif(trim("HNI_FLAG"::varchar), '') as hni_flag,
    nullif(trim("EIA_NO"::varchar), '') as eia_no,
    nullif(trim("TRF_TO_BANCS"::varchar), '') as trf_to_bancs,
    nullif(trim("BANCS_PART_ID"::varchar), '') as bancs_part_id,
    nullif(trim("MSME_FLAG"::varchar), '') as msme_flag,
    nullif(trim("MICR_CODE"::varchar), '') as micr_code,
    nullif(trim("ACC_TYPE"::varchar), '') as acc_type,
    nullif(trim("ACCOUNT_NO"::varchar), '') as account_no,
    nullif(trim("ECS_STATUS"::varchar), '') as ecs_status,
    nullif(trim("VIP_CUST"::varchar), '') as vip_cust,
    nullif(trim("EMAIL_2"::varchar), '') as email_2,
    nullif(trim("ALT_MOBILE_NO"::varchar), '') as alt_mobile_no,
    nullif(trim("ALT_EMAIL_ID"::varchar), '') as alt_email_id,
    nullif(trim("SYSTEM_IP"::varchar), '') as system_ip,
    nullif(trim("USERNAME"::varchar), '') as username,
    nullif(trim("STATUS"::varchar), '') as status,
    nullif(trim("UNIQUE_ID"::varchar), '') as unique_id,
    nullif(trim("PREFERRED_CONTACT_OPT"::varchar), '') as preferred_contact_opt,
    nullif(trim("POLICY_REF"::varchar), '') as policy_ref,
    nullif(trim("EXISTING_POLICY_PID"::varchar), '') as existing_policy_pid
    from {{ source('partner_raw', 'AZBJ_PARTNER_EXTN') }}

)

select * from source
