-- Staging model for source table BJAZ_GRP_HLT_MATERNITY_DTLS (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim("AMBULANCE"::varchar), '') as ambulance,
    nullif(trim("AMBULANCE_CHARGES"::varchar), '') as ambulance_charges,
    "AMOUNT"::number as amount,
    nullif(trim("ANNUAL_HEALTH_CHECK"::varchar), '') as annual_health_check,
    "BASE_PREMIUM"::number as base_premium,
    nullif(trim("CAESARIAN_DELIVERY"::varchar), '') as caesarian_delivery,
    "CESS1_AMT"::number as cess1_amt,
    "CESS2_AMT"::number as cess2_amt,
    "CESS3_AMT"::number as cess3_amt,
    "CGST_AMT"::number as cgst_amt,
    nullif(trim("CHILD_COVERAGE"::varchar), '') as child_coverage,
    nullif(trim("CONGENITAL_INTRNAL_DISEASE_CVR"::varchar), '') as congenital_intrnal_disease_cvr,
    nullif(trim("CORONA_PROTECTION"::varchar), '') as corona_protection,
    "CORPORATE_BUFFER"::number as corporate_buffer,
    "CORPORATE_BUFFER_CI"::number as corporate_buffer_ci,
    nullif(trim("CO_PAYMENT_PER"::varchar), '') as co_payment_per,
    nullif(trim("DAY_CARE_PROCEDURES"::varchar), '') as day_care_procedures,
    nullif(trim("DENTAL_TREATMENT"::varchar), '') as dental_treatment,
    nullif(trim("DOMICILIARY_HOSP_COVR"::varchar), '') as domiciliary_hosp_covr,
    "EDUCESS_AMT"::number as educess_amt,
    "EXCESS_MATERNITY_BENEFITSAMT"::number as excess_maternity_benefitsamt,
    nullif(trim("FAMILY_DEFINITION"::varchar), '') as family_definition,
    "GROSS_PERMIUM"::number as gross_permium,
    "ICU"::number as icu,
    "IGST_AMT"::number as igst_amt,
    "KKCESS_AMT"::number as kkcess_amt,
    nullif(trim("MATERNITY_BENEFIT"::varchar), '') as maternity_benefit,
    nullif(trim("MATERNITY_CONDITION"::varchar), '') as maternity_condition,
    "MATERNITY_COPAYMENT_AMT"::number as maternity_copayment_amt,
    "MATERNITY_COPAYMENT_PER"::number as maternity_copayment_per,
    "NCC_AMT"::number as ncc_amt,
    nullif(trim("NINE_MON_WAITING_PERIOD"::varchar), '') as nine_mon_waiting_period,
    nullif(trim("NORMAL_DELIVERY"::varchar), '') as normal_delivery,
    nullif(trim("OPT_YN"::varchar), '') as opt_yn,
    nullif(trim("OUT_PATIENT_TREATMENT"::varchar), '') as out_patient_treatment,
    nullif(trim("PARTNER_GSTN"::varchar), '') as partner_gstn,
    "PERMIUM_CO_BUFFER"::number as permium_co_buffer,
    nullif(trim("PER_FAMILY_LIMIT"::varchar), '') as per_family_limit,
    nullif(trim("PER_FAMILY_LIMIT_CI"::varchar), '') as per_family_limit_ci,
    nullif(trim("POST_HOSPITALIZATION"::varchar), '') as post_hospitalization,
    nullif(trim("PRE_HOSPITALIZATION"::varchar), '') as pre_hospitalization,
    nullif(trim("PRE_POST_NATAL_EXP"::varchar), '') as pre_post_natal_exp,
    nullif(trim("PRE_POST_NATAL_EXPENSES"::varchar), '') as pre_post_natal_expenses,
    "PRIME_RIDER_BASE_PREM"::number as prime_rider_base_prem,
    nullif(trim(to_varchar("PRODUCT")), '') as product,
    nullif(trim(to_varchar("QUOTE_NO")), '') as quote_no,
    nullif(trim(to_varchar("QUOTE_SUB_NO")), '') as quote_sub_no,
    nullif(trim(to_varchar("REG_NO")), '') as reg_no,
    nullif(trim("REMARKS_BRANCH_HO"::varchar), '') as remarks_branch_ho,
    nullif(trim("ROOM_RENT"::varchar), '') as room_rent,
    "SBCESS_AMT"::number as sbcess_amt,
    "SERTAX_AMT"::number as sertax_amt,
    "SGST_AMT"::number as sgst_amt,
    nullif(trim("TAX_CODE"::varchar), '') as tax_code,
    "TOTAL_PERMIUM"::number as total_permium,
    "UTGST_AMT"::number as utgst_amt
    from {{ source('health_raw', 'BJAZ_GRP_HLT_MATERNITY_DTLS') }}

)

select * from source
