-- Staging model for source table BJAZ_HM_COINSU_CLM_DTLS (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    "AGE"::number as age,
    nullif(trim("AILMENT"::varchar), '') as ailment,
    "AMOUNT"::number as amount,
    "AMT_OF_CLAIM_LODGED"::number as amt_of_claim_lodged,
    "CLAIM_DATE"::timestamp_ntz as claim_date,
    nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
    nullif(trim("CLAIM_PASSED"::varchar), '') as claim_passed,
    nullif(trim("CLAIM_REF"::varchar), '') as claim_ref,
    "COMNCMNT_DATE"::timestamp_ntz as comncmnt_date,
    "CO_PAYMNT_DEDUCTION"::number as co_paymnt_deduction,
    "DATE_ADMISSION"::timestamp_ntz as date_admission,
    "DATE_OF_BIRTH"::timestamp_ntz as date_of_birth,
    "DATE_OF_CL_LODGED"::timestamp_ntz as date_of_cl_lodged,
    "DATE_OF_DISCHARGE"::timestamp_ntz as date_of_discharge,
    nullif(trim("EMP_NAME"::varchar), '') as emp_name,
    nullif(trim("EMP_NO"::varchar), '') as emp_no,
    "FINAL_BILL_AMT"::number as final_bill_amt,
    nullif(trim("FINAL_DIAGNOSIS"::varchar), '') as final_diagnosis,
    nullif(trim("GROUP_NAME"::varchar), '') as group_name,
    nullif(trim("ICD_CODE"::varchar), '') as icd_code,
    nullif(trim("ID_CARD_NO"::varchar), '') as id_card_no,
    nullif(trim("INSURCO_POLICY_NO"::varchar), '') as insurco_policy_no,
    nullif(trim(to_varchar("LDR_PID")), '') as ldr_pid,
    nullif(trim("LEVEL_OF_CARE"::varchar), '') as level_of_care,
    nullif(trim("MEMBER_FLAG"::varchar), '') as member_flag,
    nullif(trim("NAME"::varchar), '') as name,
    nullif(trim("NETWORK"::varchar), '') as network,
    nullif(trim("NETWORK_CITY"::varchar), '') as network_city,
    "NON_PAYABLE_DEF_AMT"::number as non_payable_def_amt,
    "NOT_PAYABLE_EXP"::number as not_payable_exp,
    "PAID_AMOUNT"::number as paid_amount,
    nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref,
    nullif(trim("PRIMARY_PROC"::varchar), '') as primary_proc,
    nullif(trim(to_varchar("PROD_CD")), '') as prod_cd,
    "PROVIDER_NO"::number as provider_no,
    nullif(trim("REASONS"::varchar), '') as reasons,
    nullif(trim("RELATION"::varchar), '') as relation,
    nullif(trim("RFA_STATUS"::varchar), '') as rfa_status,
    nullif(trim("SEX"::varchar), '') as sex,
    nullif(trim("STATE"::varchar), '') as state,
    nullif(trim("STATUS"::varchar), '') as status,
    "SUM_INSURED"::number as sum_insured,
    "TOTAL_AMOUNT"::number as total_amount,
    nullif(trim("TYPE_OF_CLAIM"::varchar), '') as type_of_claim,
    "VALID_UPTO_DATE"::timestamp_ntz as valid_upto_date
    from {{ source('health_raw', 'BJAZ_HM_COINSU_CLM_DTLS') }}

)

select * from source
