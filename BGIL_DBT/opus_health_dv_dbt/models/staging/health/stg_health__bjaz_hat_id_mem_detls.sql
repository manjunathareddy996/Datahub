-- Staging for source table BJAZ_HAT_ID_MEM_DETLS (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("ADDLINE1")), '') as addline1,
        nullif(trim(to_varchar("ADDLINE2")), '') as addline2,
        nullif(trim(to_varchar("AGE")), '') as age,
        nullif(trim(to_varchar("ASSIGNEE")), '') as assignee,
        nullif(trim(to_varchar("CITY")), '') as city,
        nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
        nullif(trim(to_varchar("DATE_OF_BIRTH")), '') as date_of_birth,
        nullif(trim(to_varchar("DESIGNATION")), '') as designation,
        nullif(trim(to_varchar("DIABETES")), '') as diabetes,
        nullif(trim(to_varchar("DISEASE_TO_BE_EXCLUDED")), '') as disease_to_be_excluded,
        nullif(trim(to_varchar("EMAIL_ID")), '') as email_id,
        nullif(trim(to_varchar("EMP_NAME")), '') as emp_name,
        nullif(trim(to_varchar("EMP_NO")), '') as emp_no,
        nullif(trim(to_varchar("FAMILY_HIST")), '') as family_hist,
        nullif(trim(to_varchar("FAMILY_HIST_DETAILS")), '') as family_hist_details,
        nullif(trim(to_varchar("FIRST_NAME")), '') as first_name,
        nullif(trim(to_varchar("HYPERTENTION")), '') as hypertention,
        nullif(trim(to_varchar("ID_CARD_NO")), '') as id_card_no,
        nullif(trim(to_varchar("IHD")), '') as ihd,
        nullif(trim(to_varchar("JOIN_DATE")), '') as join_date,
        nullif(trim(to_varchar("LAST_NAME")), '') as last_name,
        nullif(trim(to_varchar("MARRIAGE_DATE")), '') as marriage_date,
        nullif(trim(to_varchar("MEMBER_NO")), '') as member_no,
        nullif(trim(to_varchar("MIDDLE_NAME")), '') as middle_name,
        nullif(trim(to_varchar("OTHER_DISEASES")), '') as other_diseases,
        nullif(trim(to_varchar("PART_ID")), '') as part_id,
        nullif(trim(to_varchar("PIN")), '') as pin,
        nullif(trim(to_varchar("PREMIUM")), '') as premium,
        nullif(trim(to_varchar("PREV_POLICY_DETAILS")), '') as prev_policy_details,
        nullif(trim(to_varchar("PREV_POL_CLM_AMT")), '') as prev_pol_clm_amt,
        nullif(trim(to_varchar("PROFESSION")), '') as profession,
        nullif(trim(to_varchar("RELATION")), '') as relation,
        nullif(trim(to_varchar("RENAL_PROBLEM")), '') as renal_problem,
        nullif(trim(to_varchar("SEX")), '') as sex,
        nullif(trim(to_varchar("STATE")), '') as state,
        nullif(trim(to_varchar("STATUS")), '') as status,
        nullif(trim(to_varchar("SUM_INSURED")), '') as sum_insured,
        nullif(trim(to_varchar("TEL")), '') as tel
    from {{ source('health_raw', 'BJAZ_HAT_ID_MEM_DETLS') }}

)

select * from source
